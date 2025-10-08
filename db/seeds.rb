puts "Cleaning database..."
User.destroy_all

puts "Creating users..."

users = [
  { email: "user1@example.com", password: "password123" },
  { email: "user2@example.com", password: "password123" },
  { email: "user3@example.com", password: "password123" },
  { email: "user4@example.com", password: "password123" }
]

users.each do |attrs|
  user = User.create!(attrs)
  puts "Created #{user.email}"
end

puts "Seeding done!"