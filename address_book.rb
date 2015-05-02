require "./contact"
require "yaml"

class AddressBook
  attr_reader :contacts

  # constructor
  def initialize
    @contacts = []
    open
  end

  # load contact file
  def open
    if File.exists?("contacts.yml")
      @contacts = YAML.load_file("contacts.yml")
    end
  end

  # save changes to file
  def save
    File.open("contacts.yml", "w") do |file|
      file.write(contacts.to_yaml)
    end
  end

  # main loop to run program
  def run
    loop do
      puts "********** Address book **********"
      puts "*   a: Add contact               *"
      puts "*   p: Print contact list        *"
      puts "*   s: Search                    *"
      puts "*   d: Delete                    *"
      puts "*   e: Exit                      *"
      puts "**********************************"
      print "Enter your choice: "
      input = gets.chomp.downcase
      case input
      when 'a'
        add_contact
      when 'p'
        print_contact_list
      when 's'
        print "Search term: "
        search = gets.chomp
        find_by_name search
        find_by_address search
        find_by_phone_number search
      when 'd'
        print "Enter the contact you whish to delete: "
        input = gets.chomp.to_i
        number = input - 1
        delete number
      when 'e'
        save
        break
      end
    end
  end

  # deletes a contact from the address book
  def delete number
   if !contacts.delete_at(number).nil?
     puts "The contact has been successfully  deleted!\n"
   else
     puts "The contact has not been deleted or does not exist!\n"
   end
  end

  # adds a new contact to the address book
  def add_contact
    contact = Contact.new
    print "First name: "
    contact.first_name = gets.chomp
    print "Middle name: "
    contact.middle_name = gets.chomp
    print "Last name: "
    contact.last_name = gets.chomp
    loop do
      puts "Add phone number or address?"
      puts "p: Add phone number"
      puts "a: Add address"
      puts "(Any other key to go back)"
      print ">"
      response = gets.chomp
      case response
      when 'p'
        phone = new_phone
        contact.phone_numbers.push phone
      when 'a'
        address = new_address
        contact.addresses.push address
      else
        print "\n"
        break
      end
    end
    contacts.push contact
  end

  # creates a new phone number
  def new_phone
    phone = PhoneNumber.new
    print "Phone number kind (Home, Office, ecc.): "
    phone.kind = gets.chomp
    print "Number: "
    phone.number = gets.chomp
    phone
  end

  # creates a new address
  def new_address
    address = Address.new
    print "Address kind (Home, Office, ecc.): "
    address.kind = gets.chomp
    print "Street 1:  "
    address.street_1 = gets.chomp
    print "Street 2:  "
    address.street_2 = gets.chomp
    print "City:  "
    address.city = gets.chomp
    print "State:  "
    address.state = gets.chomp
    print "Postal Code:  "
    address.postal_code = gets.chomp
    address
  end

  # searches and prints a contact by name
  def find_by_name(name)
    results = []
    search = name.downcase
    contacts.each do |contact|
      if contact.full_name.downcase.include?(search)
        results.push(contact)
      end
    end
    print_results("Name search results (#{search})", results)
  end

  # searches and prints a contact by phone number
  def find_by_phone_number(number)
    results = []
    search = number.gsub("_", "")
    contacts.each do |contact|
      contact.phone_numbers.each do |phone_number|
        if phone_number.number.gsub("-", "").include?(search)
          results.push(contact) unless results.include?(contact)
        end
      end
    end
    print_results("Phone search results (#{search})", results)
  end

  # searches and prints a contact by address
  def find_by_address(query)
    results = []
    search = query.downcase
    contacts.each do |contact|
      contact.addresses.each do |address|
        if address.to_s('long').downcase.include?(search)
          results.push(contact) unless results.include?(contact)
        end
      end
    end
    print_results("Address search results #{search}", results)
  end

  # prints the address book
  def print_contact_list
    puts "-- Contact list --\n\n"
    i = 1
    contacts.each do |contact|
      print "#{i}) "
      puts contact.to_s('last_first')
      i += 1
    end
  end

  # prints the results of a search
  def print_results(search, results)
    puts search
    results.each do |contact|
      puts contact.to_s('full_name')
      contact.print_phone_numbers
      contact.print_addresses
      puts "\n"
    end
  end

end


# creates a new address book and runs the loop that handles it
address_book = AddressBook.new
address_book.run
