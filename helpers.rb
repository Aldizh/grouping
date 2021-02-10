def parse_phone_text(text)
  if !text
    return nil
  end
  digits = text.tr('^0-9', '') # trim non-digits
  if digits[0] == '1'
    digits[0] = '' # remove U.S prefix if there is any
  end
  return digits
end

def get_file_name
  print "Please enter the input file name (e.g: input1.csv | input2.csv | input3.csv) : "
  name = gets.chomp

  return name
end

def get_criteria_from_user
  puts "Please select one of the matching criteria: \n1 -> email address \n2 -> phone number \n3 -> email or phone"
  print ": "
  criteria = gets.chomp.to_i

  while ![1, 2, 3].include?(criteria)
    puts "Sorry, invalid selection"
    puts "Please select one of the matching criteria: \n1 -> email address \n2 -> phone number \n3 -> email or phone"
    print ": "
    criteria = gets.chomp.to_i
  end

  puts "Thank you, your file is ready, it will be under output.csv"

  return criteria
end

def sync_email_hash(row, email_hash, lineno)
  email1 = row[4] && row[4].size && row[4]
  email2 = row[5] && row[5].size && row[5]
  if email1 && !email_hash[email1]
    if email2 && email_hash[email2]
      email_hash[email1] = email_hash[email2]
    else
      email_hash[email1] = lineno
    end
  end

  if email2 && !email_hash[email2]
    if email1 && email_hash[email1]
      email_hash[email2] = email_hash[email1]
    else
      email_hash[email2] = lineno
    end
  end
  return email_hash
end

def sync_phone_hash(row, phone_hash, lineno)
  phone1 = row[2] && row[2].size && parse_phone_text(row[2])
  phone2 = row[3] && row[3].size && parse_phone_text(row[3])
  if phone1 && !phone_hash[phone1]
    if phone2 && phone_hash[phone2]
      phone_hash[phone1] = phone_hash[phone2]
    else
      phone_hash[phone1] = lineno
    end
  end

  if phone2 && !phone_hash[phone2]
    if phone1 && phone_hash[phone1]
      phone_hash[phone2] = phone_hash[phone1]
    else
      phone_hash[phone2] = lineno
    end
  end
  return phone_hash
end

def sync_phone_or_email_hash(row, phone_or_email, lineno)
  phone1 = row[2] && row[2].size && parse_phone_text(row[2])
  phone2 = row[3] && row[3].size && parse_phone_text(row[3])
  email1 = row[4]
  email2 = row[5]
  if phone1 && !phone_or_email[phone1]
    if phone_or_email[phone2]
      phone_or_email[phone1] = phone_or_email[phone2]
    elsif phone_or_email[email1]
      phone_or_email[phone1] = phone_or_email[email1]
    elsif phone_or_email[email2]
      phone_or_email[phone1] = phone_or_email[email2]
    else
      phone_or_email[phone1] = lineno
    end
  end
  if phone2 && !phone_or_email[phone2]
    if phone_or_email[phone1]
      phone_or_email[phone2] = phone_or_email[phone1]
    elsif phone_or_email[email1]
      phone_or_email[phone2] = phone_or_email[email1]
    elsif phone_or_email[email2]
      phone_or_email[phone2] = phone_or_email[email2]
    else
      phone_or_email[phone2] = lineno
    end
  end
  if email1 && !phone_or_email[email1]
    if phone_or_email[phone1]
      phone_or_email[email1] = phone_or_email[phone1]
    elsif phone_or_email[phone2]
      phone_or_email[email1] = phone_or_email[phone2]
    elsif phone_or_email[email2]
      phone_or_email[email1] = phone_or_email[email2]
    else
      phone_or_email[email1] = lineno
    end
  end
  if email2 && !phone_or_email[email2]
    if phone_or_email[phone1]
      phone_or_email[email2] = phone_or_email[phone1]
    elsif phone_or_email[phone2]
      phone_or_email[email2] = phone_or_email[phone2]
    elsif phone_or_email[email1]
      phone_or_email[email2] = phone_or_email[email1]
    else
      phone_or_email[email2] = lineno
    end
  end
  return phone_or_email
end