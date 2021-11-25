require 'csv'

def clean_zipcode(zipcode)
  while zipcode.length < 5
    zipcode = "0#{zipcode}"
  end
  zipcode
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode].to_s
  puts "#{name} #{clean_zipcode(zipcode)}"
end