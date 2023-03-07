# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts "Clearing database..."

Day.destroy_all
Bookmark.destroy_all
Route.destroy_all
User.destroy_all

admin = User.create!(email: "admin@tabinav.com", password: "password", first_name: "Tabinav", last_name: "Yeah", passport_no: "123456789")


puts "Email: admin@tabinav.com \nPassword: password"
puts "---\n"
puts "Creating 5 routes..."

destinations = ["France", "Dolomites", "California", "New Zealand", "Turkey"]

destinations.each do |destination|
  start_date = Date.today + 7
  end_date = start_date + rand(7..20)
  route = Route.create!(destination: destination, user: admin, budget: 10000, total_price: 9000, start_date: start_date, end_date: end_date)
  # Bookmark.create!(description: "testing", route: route)
  puts "Creating days"
    rand(2..5).times do
      Day.create!(name: Faker::Sports::Mountaineering.mountaineer, description: Faker::Lorem.paragraph, route: route)
    end
  puts "Creating days finished"
end
puts "5 routes created."
