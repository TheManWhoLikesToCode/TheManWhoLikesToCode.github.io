require 'net/http'
require 'json'
require 'date'
require 'base64'

GITHUB_USERNAME = 'TheManWhoLikesToCode'
GITHUB_API_URL = "https://api.github.com/users/#{GITHUB_USERNAME}/repos"

# Setup http request with the token
http = Net::HTTP.new(URI(GITHUB_API_URL).host, URI(GITHUB_API_URL).port)
http.use_ssl = true
request = Net::HTTP::Get.new(URI(GITHUB_API_URL))
request["Authorization"] = "token #{ENV['GH_TOKEN']}"

# Fetch repositories from GitHub
response = http.request(request)
repositories = JSON.parse(response.body)

# Debug: Check the number of fetched repositories
puts "Fetched #{repositories.length} repositories"

# Loop through repositories and create posts
repositories.each do |repo|
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

  # Check if the response contains README data or an error message
  begin
    readme = JSON.parse(readme_response.body)
    if readme['message'] && readme['message'] == 'Not Found'
      readme_content = "No README available for this repository."
    else
      # Decode README content from base64
      readme_content = Base64.decode64(readme['content'])
    end
  rescue JSON::ParserError
    readme_content = "Error parsing README data."
  end

  # Debug: Print the title of the repo being processed
  puts "Processing #{title}"

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

  # Debug: Check git operations
  puts "Adding files to git"
  puts `git add .`
  
  puts "Committing files to git"
  commit_output = `git commit -m 'Add new post: #{title}'`
  puts commit_output
  
  if commit_output.include?("nothing to commit")
    puts "Nothing new to commit."
  else
    puts "Pushing changes to remote repository"
    # Use the token when pushing changes
    puts `git push https://x-access-token:#{ENV['GH_TOKEN']}@github.com/#{GITHUB_USERNAME}/TheManWhoLikesToCode.github.io.git`
  end
end
