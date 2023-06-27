require 'net/http'
require 'json'
require 'date'
require 'base64'

GITHUB_USERNAME = 'TheManWhoLikesToCode'
GITHUB_API_URL = "https://api.github.com/users/#{GITHUB_USERNAME}/repos"

# Fetch repositories from GitHub
puts "Fetching repositories from GitHub..."
uri = URI(GITHUB_API_URL)
response = Net::HTTP.get(uri)
repositories = JSON.parse(response)

puts "Found #{repositories.length} repositories."

# Loop through repositories and create posts
repositories.each do |repo|
  title = repo['name']
  description = repo['description']
  url = repo['html_url']
  date = Date.today.strftime("%Y-%m-%d")

  puts "Creating post for repository: #{title}"

  # Fetch README
  readme_uri = URI("https://api.github.com/repos/#{GITHUB_USERNAME}/#{title}/readme")
  readme_response = Net::HTTP.get(readme_uri)
  readme = JSON.parse(readme_response) rescue nil

  # Decode README content from base64
  readme_content = readme && readme['content'] ? Base64.decode64(readme['content']) : "No README available for this repository."

  # Create the post file
  Dir.mkdir("../_posts") unless Dir.exist?("..`/_posts")
  File.open("../_posts/#{date}-#{title}.markdown", "w") do |file|
    file.puts("---")
    file.puts("layout: post")
    file.puts("title: #{title}")
    file.puts("description: #{description}")
    file.puts("---")
    file.puts(readme_content)
    file.puts("[Go to repository](#{url})")
  end

  puts "Post for repository: #{title} created."
end

puts "All posts created."
