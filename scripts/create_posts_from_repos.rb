require 'net/http'
require 'json'
require 'date'
require 'base64'

GITHUB_USERNAME = 'TheManWhoLikesToCode'
GITHUB_API_URL = "https://api.github.com/users/#{GITHUB_USERNAME}/repos"

# Function to convert relative links to absolute GitHub URLs
def convert_relative_links_to_absolute(content, username, repository)
  content.gsub(/\(.\//, "(https://raw.githubusercontent.com/#{username}/#{repository}/master/")
end

# Setup http request with the token
http = Net::HTTP.new(URI(GITHUB_API_URL).host, URI(GITHUB_API_URL).port)
http.use_ssl = true
request = Net::HTTP::Get.new(URI(GITHUB_API_URL))
request["Authorization"] = "token #{ENV['GH_TOKEN']}"

# Fetch repositories from GitHub
response = http.request(request)
repositories = JSON.parse(response.body)

# Check if repositories is an array (expected), or something else
unless repositories.is_a?(Array)
  puts "Unexpected response format. Exiting."
  exit
end

# Debug: Check the number of fetched repositories
puts "Fetched #{repositories.length} repositories"

# Loop through repositories and create posts
repositories.each do |repo|
  begin
    title = repo['name']
    description = repo['description']
    url = repo['html_url']

    # Extract the creation date and format it
    creation_date = DateTime.parse(repo['created_at']).strftime("%Y-%m-%d")

    # Fetch README
    readme_uri = URI("https://api.github.com/repos/#{GITHUB_USERNAME}/#{title}/readme")
    readme_request = Net::HTTP::Get.new(readme_uri)
    readme_request["Authorization"] = "token #{ENV['GH_TOKEN']}"
    readme_response = http.request(readme_request)
    readme = JSON.parse(readme_response.body)

    # Decode README content from base64
    readme_content = Base64.decode64(readme['content'])

    # Convert relative links to absolute GitHub URLs
    readme_content = convert_relative_links_to_absolute(readme_content, GITHUB_USERNAME, title)

    # Create the post file
    File.open("_posts/#{creation_date}-#{title}.markdown", "w") do |file|
      file.puts("---")
      file.puts("layout: post")
      file.puts("title: #{title}")
      file.puts("description: #{description}")
      file.puts("---")
      file.puts(readme_content)
      file.puts("[Go to repository](#{url})")
    end

  rescue Exception => e
    puts "An error occurred processing the repository #{title}: #{e.message}"
  end
end

# Debug: Check git operations after processing all repositories
puts "Adding files to git"
puts `git add .`

puts "Committing files to git"
commit_output = `git commit -m 'Add new posts from repositories'`
puts commit_output

if commit_output.include?("nothing to commit")
  puts "Nothing new to commit."
else
  puts "Pushing changes to remote repository"
  # Use the token when pushing changes
  puts `git push https://x-access-token:#{ENV['GH_TOKEN']}@github.com/#{GITHUB_USERNAME}/TheManWhoLikesToCode.github.io.git`
end
