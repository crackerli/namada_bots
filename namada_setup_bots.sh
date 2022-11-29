#!/usr/bin/expect -f

# Regular expression to find out lines contain mnemonic words.
REG_MNEMONIC_WORDS='^[0-9]{1,2}. *'
# Regular expression to find out lines that have only digital numbers.
REG_PURE_DIGITS='^[0-9]{1,2}'

OLD_IFS="$IFS"

# Array to store the intermediate result that has digital numbers, with a head entry.
temp_words=("head")
# Array to store the true mnemonic words.
final_words=()

IFS="."

log_file expect_output.log

spawn namada-ts contribute default https://contribute.namada.net $0

expect "*Do you want to participate anonymously (if not, you’ll be asked to provide us with your name and email address)*"
send "y\r"

expect "*Press enter to generate a keypair*"

send "\r"

expect "*======================*"

send "\r"

# First round to read out all the lines contain mnemonic words and split each line
# into words array with digital numbers.
while read line
do
    if [[ $line =~ $REG_MNEMONIC_WORDS ]] ; then
      # Split line into array with '.'
      temp_array=($line)

      # If the entry has only a digital number, ignore it, otherwise add them into temp_words.
      for entry in ${temp_array[@]}
      do
        if [[ $entry =~ $REG_PURE_DIGITS ]]; then
          echo 'This is only a digital number: ' $entry
        else
          temp_words+=($entry)
        fi
      done
    fi
done < expect_output.log

# Second round to remove each entry's whitespaces and digital numbers.
for raw_word in ${temp_words[@]}
do
  # Remove all whitespaces
  temp=$(echo $raw_word | sed 's/ //g')
  # Remove digital numbers
  final_word=$(echo $temp | sed 's/[0-9]\+$//')
  final_words+=($final_word)
done

REG_VERIFY_WORDS='^Enter the word at index*'
# Array to store instructions for each step
verify_prompt_array1=()
verify_prompt_array2=()
verify_prompt_array3=()

expect "*Enter the word at index*"

first_slot=0

while read verify_line1
do
    if [[ $verify_line1 =~ $REG_VERIFY_WORDS ]] ; then
      verify_prompt_array1+=($verify_line1)
    fi
done < expect_output.log

# Parse the 1st verify prompt and get slot number
first_slot=$(echo ${verify_prompt_array1[0]} | tr -dc '0-9')

send "${final_words[first_slot]}\r"

expect "*Enter the word at index*"
second_slot=0

while read verify_line2
do
    if [[ $verify_line2 =~ $REG_VERIFY_WORDS ]] ; then
      verify_prompt_array2+=($verify_line2)
    fi
done < expect_output.log

# Parse the 2nd verify prompt and get slot number
second_slot=$(echo ${verify_prompt_array2[1]} | tr -dc '0-9')
send "${final_words[second_slot]}\r"

expect "*Enter the word at index*"
third_slot=0

while read verify_line3
do
    if [[ $verify_line3 =~ $REG_VERIFY_WORDS ]] ; then
      verify_prompt_array3+=($verify_line3)
    fi
done < expect_output.log

# Parse the 3rd verify prompt and get slot number
second_slot=$(echo ${verify_prompt_array3[1]} | tr -dc '0-9')
send "${final_words[third_slot]}\r"
