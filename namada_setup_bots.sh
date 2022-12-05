#!/usr/bin/expect -d

set TOKEN [lindex $argv 0]

spawn namada-ts contribute default https://contribute.namada.net $TOKEN

expect "*Do you want to participate anonymously (if not, you’ll be asked to provide us with your name and email address)*"
send "y\r"

expect "*Press enter to generate a keypair*"

send "\r"

set time_now [clock format [clock seconds] -format "%Y-%m-%d-%H-%M-%S"]

set mnemonic_log_file "mnemonic_log-$time_now.txt"

# Start recording mnemonics info
log_file $mnemonic_log_file

expect "*Press enter when you've done it*"

# Stop recording
log_file

set record_mnemonic_file "./$mnemonic_log_file"
set record_mnemonic_file_id [open $record_mnemonic_file r]

set mnemonics_string ""
set mnemonic_pattern {[1-9]*}
while {1} {
    set read_line [gets $record_mnemonic_file_id]
    if {[eof $record_mnemonic_file_id]} {
        close $record_mnemonic_file_id
        break
    }

    if {[string match $mnemonic_pattern $read_line]} {
        append mnemonics_string $read_line
    }
}

set raw_mnemonics [split $mnemonics_string .]

set final_mnemonics [list]
foreach raw_mnemonic $raw_mnemonics {
    set temp_mnemonics [split $raw_mnemonic " "]
    set pure_mnemonic [lindex $temp_mnemonics 1]
    lappend final_mnemonics $pure_mnemonic
}

send "\r"

set index_pattern {[1-9]*}
expect "*Enter the word at index*"

set raw_ins1 [split $expect_out(buffer) " "]
foreach ins1_index $raw_ins1 {
    if {[string match $index_pattern $ins1_index]} {
        puts "first index wanted: $ins1_index"
        set first_mnemonic [lindex $final_mnemonics $ins1_index]
        send "$first_mnemonic\r"
    }
}

expect "*Enter the word at index*"

set raw_ins2 [split $expect_out(buffer) " "]
foreach ins2_index $raw_ins2 {
    if {[string match $index_pattern $ins2_index]} {
        puts "second index wanted: $ins2_index"
        set second_mnemonic [lindex $final_mnemonics $ins2_index]
        send "$second_mnemonic\r"
    }
}

expect "*Enter the word at index*"

set raw_ins3 [split $expect_out(buffer) " "]
foreach ins3_index $raw_ins3 {
    if {[string match $index_pattern $ins3_index]} {
        puts "first index wanted: $ins3_index"
        set third_mnemonic [lindex $final_mnemonics $ins3_index]
        send "$third_mnemonic\r"
    }
}



expect "*1Joining Queue1*"
set timeout -1
puts "Mnemonics verification succeeded, good luck to you!!"

