require 'net/http'
require 'json'
require 'date'
require 'base64'

GITHUB_USERNAME = 'TheManWhoLikesToCode'
GITHUB_API_URL = "https://api.github.com/users/#{GITHUB_USERNAME}/repos"

# Function to extract the description section from the README content
def extract_description_section(readme_content)
  match = readme_content.match(/## Description\n(.*?)(\n##|$)/m)
  if match
    match[1].strip
  else
    'Description not found'
  end
end

# Function to execute an HTTP request with error handling
def execute_http_request(http, request)
  response = http.request(request)
  if response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  else
    puts "HTTP Error: #{response.code} - #{response.message}"
    nil
  end
end

# Setup http request with the token
http = Net::HTTP.new(URI(GITHUB_API_URL).host, URI(GITHUB_API_URL).port)
http.use_ssl = true
request = Net::HTTP::Get.new(URI(GITHUB_API_URL))
request["Authorization"] = "token #{ENV['GH_TOKEN']}"

# Fetch repositories from GitHub
repositories = execute_http_request(http, request)

# Validate repositories response
if repositories.nil? || !repositories.is_a?(Array)
  puts "Unexpected response format. Exiting."
  exit
end

# Debug: Check the number of fetched repositories
puts "Fetched #{repositories.length} repositories"

# Loop through repositories and create posts
repositories.each do |repo|
  begin
    title = repo['name']
    url = repo['html_url']
    language = repo['language']
    stars = repo['stargazers_count']

    # Extract the creation date and format it
    creation_date = DateTime.parse(repo['created_at']).strftime("%Y-%m-%d")

    # Fetch README
    readme_uri = URI("https://api.github.com/repos/#{GITHUB_USERNAME}/#{title}/readme")
    readme_request = Net::HTTP::Get.new(readme_uri)
    readme_request["Authorization"] = "token #{ENV['GH_TOKEN']}"
    readme = execute_http_request(http, readme_request)

    # Decode README content from base64
    readme_content = Base64.decode64(readme['content'])

    # Extract description section
    description = extract_description_section(readme_content)

    # Create the post file
    File.open("_posts/#{creation_date}-#{title}.markdown", "w") do |file|
      file.puts("---")
      file.puts("layout: post")
      file.puts("title: #{title}")
      file.puts("language: #{language}")
      file.puts("stars: #{stars}")
      file.puts("---")
      file.puts(description)
      file.puts("[Find out more in the repository](#{url})")
    end

    puts "Processed repository: #{title}"

  rescue Exception => e
    puts "An error occurred processing the repository #{title}: #{e.message}"
  end
end

# Debug: Check git operations after processing all repositories
puts "Adding files to git"
# Adding files to git
puts `git add .`

# Check if there are changes to be committed
status = `git status --porcelain`
if status.empty?
  puts "Nothing new to commit."
  exit 0 # <-- Explicitly exiting with a 'success' status code
else
  # Commit and push changes
  puts "Committing files to git"
  puts `git commit -m 'Add new posts from repositories'`
  puts "Pushing changes to remote repository"
  puts `git push https://x-access-token:#{ENV['GH_TOKEN']}@github.com/#{GITHUB_USERNAME}/TheManWhoLikesToCode.github.io.git`
  
  # Exit with a success status code
  exit 0
end
