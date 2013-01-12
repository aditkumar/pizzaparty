require 'rubygems'
require 'json'
require_relative 'ordrin'
require_relative 'utils'

def _get_open_pizzerias(delivery_time, current_loc)
  r_api = OrdrIn::Restaurant.new
  
  r_all = JSON.parse(r_api.delivery_list(delivery_time, current_loc))
  # r_all = r_all.select {|hash| hash['is_delivering'] == 1 }
  r_all = r_all.select {|hash| hash['na'].downcase =~ /.*pizz(a|eria).*/}
  
  r_all
end

# order_pizza method takes two parameters:
# => address (OrdrIn::Address.new(street, city, postal code, street2, state, phone, desc))
# => num_pizzas (Integer) - number of pizzas to order
def order_pizza(current_loc, num_pizzas, first_name, last_name, card_number, card_cvc, card_exp, cc_addr)
  $api = OrdrIn::API.new("t1gew_pQWghMUgXcvua718JHdighm1Cc60QTT_ufHG8", "https://r-test.ordr.in")
  r_api = OrdrIn::Restaurant.new

  # ASAP Pizza Party
  delivery_time = OrdrIn::DT.new
  delivery_time.asap = true

  # Get a list of all open restaurants with pizza in their name
  r_all = _get_open_pizzerias(delivery_time, current_loc)
  r_chosen = r_all.sample
  
  if r_chosen.nil?
    # ERROR: No open restaurants
    puts "Oh no! Looks like all the pizza places are closed"
    exit
  else
    puts "Chosen Restaurant: " + r_chosen.inspect
  end

  # Create a somewhat understandable menu from this json object jungle
  final_menu = Array.new
  clean_menu = Hash.new
  menu = JSON.parse(r_api.details(r_chosen['id']))
  menu.flatten_with_path.each {|key, val|
    if key =~ /^menu.*(id|name|price)$/ && !val.empty?
      if key =~ /^menu.*id$/
        if !clean_menu["id"].nil?
          # puts "    ERROR: " + key
          clean_menu = Hash.new
        end
        clean_menu["id"] = val
      elsif key =~ /^menu.*name$/
        if !clean_menu["name"].nil?
          #puts "    ERROR: " + key
          clean_menu = Hash.new
        end
        clean_menu["name"] = val
      # elsif key =~ /^menu.*descrip$/
      #       if !clean_menu["name"].nil?
      #         #puts "    ERROR: " + key
      #         clean_menu = Hash.new
      #       end
      #       clean_menu["name"] = val
      else
        if !clean_menu["price"].nil?
          # puts "    ERROR: " + key
          clean_menu = Hash.new
        end
        clean_menu["price"] = val
      end
    
      if !clean_menu["id"].nil? && !clean_menu["name"].nil? && !clean_menu["price"].nil?
        final_menu.push clean_menu
        clean_menu = Hash.new
      end
    end
  }
  
  # Hack for Mama's Pizza
  final_menu = final_menu[1, 10]
  
  subtotal = 0
  tray = ""
  pizzas = Array.new
  # Pick some pizzas at random
  num_pizzas.times do
    another_pizza = final_menu.sample
    pizzas.push another_pizza
    
    subtotal += another_pizza["price"].to_f
    
    if !tray.empty?
      tray += "+"
    end
    tray += another_pizza["id"] + "/1"
  end
  
  puts "Ordering Pizzas: $" + subtotal.to_s + " " + pizzas.inspect
  # Create the order
  # submit(id, tray, tip, dt, email, first_name, last_name, addr, card_name, card_number, card_cvc, card_exp, cc_addr)
  $api = OrdrIn::API.new("t1gew_pQWghMUgXcvua718JHdighm1Cc60QTT_ufHG8", "https://o-test.ordr.in") # Apparently orders require a different API url...
  order = OrdrIn::Order.new
  tray += "+8644260/1" # Adding a salad because pizzas are free at Mama's (???)
  puts order.submit(r_chosen["id"], tray, OrdrIn::Money.new(subtotal * 0.15), delivery_time, "test@pizzapartay.com", first_name, last_name, current_loc, first_name + " " + last_name, card_number, card_cvc, card_exp, cc_addr)
end

# Test
order_pizza(
    OrdrIn::Address.new("500 7th Ave", "New York", "10018", "17th Floor", "NY", "7777777777", "Alley NYC"),
    3,
    "John",
    "Doe",
    "4111111111111111",
    "123",
    "02/2016",
    OrdrIn::Address.new("500 7th Ave", "New York", "10018", "17th Floor", "NY", "7777777777", "Alley NYC")
    )