require 'httparty'

puts "🧹 Cleaning existing data..."
Product.destroy_all
Category.destroy_all
Brand.destroy_all
Page.destroy_all if defined?(Page)

puts "🌱 Seeding clothing products from DummyJSON..."

categories = {
  "mens-shirts" => "Men's Shirts",
  "mens-shoes" => "Men's Shoes",
  "womens-dresses" => "Women's Dresses",
  "womens-shoes" => "Women's Shoes",
  "tops" => "Tops",
  "womens-bags" => "Women's Bags",
  "sunglasses" => "Sunglasses"
}

product_counter = 0

categories.each do |slug, display_name|
  puts "📦 Fetching #{display_name}..."
  category = Category.find_or_create_by!(name: display_name)

  response = HTTParty.get("https://dummyjson.com/products/category/#{slug}?limit=100")
  products = response.parsed_response["products"]

  products.each do |item|
    brand = Brand.find_or_create_by!(name: item["brand"])

    product = Product.create!(
      name: item["title"],
      description: item["description"],
      price: item["price"].to_f,
      stock: rand(5..30),
      brand: brand
    )
    product.categories << category
    product_counter += 1

    2.times do |i|
      variant = Product.create!(
        name: "#{item["title"]} (Variant #{i + 1})",
        description: "#{item["description"]} This is a variant version.",
        price: (item["price"].to_f + rand(-5.0..5.0)).round(2),
        stock: rand(5..30),
        brand: brand
      )
      variant.categories << category
      product_counter += 1
    end
  end
end

puts "✅ Seeded #{product_counter} clothing products across #{Category.count} categories."

# 🌱 Seed About & Contact Pages
puts "📝 Creating editable static pages..."

Page.find_or_create_by!(slug: "about") do |page|
  page.title = "About Us"
  page.content = "StreetStitch was born in a Winnipeg garage by fashion lovers who wanted to bring bold streetwear to everyday people. What started as a passion turned into a community."
end

Page.find_or_create_by!(slug: "contact") do |page|
  page.title = "Contact Us"
  page.content = "Reach out to us at support@streetstitch.ca or message us on Instagram @streetstitch. We're always here to help!"
end

puts "✅ About and Contact pages created successfully."

# 🌎 Seed Provinces (safely without deleting existing associations)
puts "🌍 Seeding provinces (create or update)..."

province_data = [
  { name: "Alberta", pst: 0.0, gst: 0.05, hst: 0.0 },
  { name: "British Columbia", pst: 0.07, gst: 0.05, hst: 0.0 },
  { name: "Manitoba", pst: 0.07, gst: 0.05, hst: 0.0 },
  { name: "New Brunswick", pst: 0.0, gst: 0.0, hst: 0.15 },
  { name: "Newfoundland and Labrador", pst: 0.0, gst: 0.0, hst: 0.15 },
  { name: "Northwest Territories", pst: 0.0, gst: 0.05, hst: 0.0 },
  { name: "Nova Scotia", pst: 0.0, gst: 0.0, hst: 0.15 },
  { name: "Nunavut", pst: 0.0, gst: 0.05, hst: 0.0 },
  { name: "Ontario", pst: 0.0, gst: 0.0, hst: 0.13 },
  { name: "Prince Edward Island", pst: 0.0, gst: 0.0, hst: 0.15 },
  { name: "Quebec", pst: 0.09975, gst: 0.05, hst: 0.0 },
  { name: "Saskatchewan", pst: 0.06, gst: 0.05, hst: 0.0 },
  { name: "Yukon", pst: 0.0, gst: 0.05, hst: 0.0 }
]

province_data.each do |attrs|
  Province.find_or_create_by!(name: attrs[:name]).update!(attrs)
end

puts "✅ Provinces seeded successfully."

# 👮 Admin User (ActiveAdmin)
if Rails.env.development? && defined?(AdminUser)
  AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
    admin.password = 'password'
    admin.password_confirmation = 'password'
  end
  puts "🔑 Admin user created: admin@example.com / password"
end
