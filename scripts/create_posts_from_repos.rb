require 'net/http'
require 'json'
require 'date'

GITHUB_USERNAME = 'YourGitHubUsername'
GITHUB_API_URL = "https://api.github.com/users/#{GITHUB_USERNAME}/repos"

# Fetch repositories from GitHub
uri = URI(GITHUB_API_URL)
response = Net::HTTP.get(uri)
repositories = JSON.parse(response)

# Loop through repositories and create posts
repositories.each do |repo|
  title = repo['name']
  description = repo['description']
  url = repo['html_url']
  date = Date.today.strftime("%Y-%m-%d")

  # Create the post file
  File.open("_posts/#{date}-#{title}.markdown", "w") do |file|
    file.puts("---")
    file.puts("layout: post")
    file.puts("title: #{title}")
    file.puts("description: #{description}")
    file.puts("---")
    file.puts("[Go to repository](#{url})")
  end
end
