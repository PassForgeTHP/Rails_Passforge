# Seeds for PassForge application
# Only seed in development and staging environments to avoid data loss in production

if Rails.env.production?
  puts "WARNING: Skipping seeds in production environment to avoid data loss"
  puts "Run 'FORCE_SEED=true rails db:seed' to force seeding in production"
  exit unless ENV['FORCE_SEED'] == 'true'
end

puts "Starting database seeding..."
puts "Environment: #{Rails.env}"

# Clean existing data (only if not production or forced)
if Rails.env.development? || ENV['FORCE_SEED'] == 'true'
  puts "\nCleaning database..."
  User.destroy_all
  puts "Database cleaned"
end

puts "\nCreating users..."

users_data = [
  {
    name: "Alice Demo",
    email: "alice@passforge.demo",
    password: "SecurePass123!",
    password_confirmation: "SecurePass123!"
  },
  {
    name: "Jean Dupont",
    email: "jean@passforge.demo",
    password: "SecurePass123!",
    password_confirmation: "SecurePass123!"
  },
  {
    name: "Paul Martin",
    email: "paul@passforge.demo",
    password: "SecurePass123!",
    password_confirmation: "SecurePass123!"
  },
  {
    name: "Sophie Bernard",
    email: "sophie@passforge.demo",
    password: "SecurePass123!",
    password_confirmation: "SecurePass123!"
  }
]

created_users = []

users_data.each do |attrs|
  user = User.find_or_create_by(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = attrs[:password]
    u.password_confirmation = attrs[:password_confirmation]
  end

  if user.persisted?
    created_users << user
    puts "  Created: #{user.name} (#{user.email})"
  else
    puts "  Failed to create #{attrs[:email]}: #{user.errors.full_messages.join(', ')}"
  end
end

puts "\nSeeding Summary:"
puts "  - Users created: #{created_users.count}"
puts "  - Total users in DB: #{User.count}"

puts "\nSeeding completed successfully!"

if Rails.env.development?
  puts "\nTest credentials:"
  puts "  Email: alice@passforge.demo"
  puts "  Password: SecurePass123!"
end