require 'net/http'
require 'json'
require 'date'
require 'base64'

GITHUB_USERNAME = 'TheManWhoLikesToCode'
GITHUB_API_URL = "https://api.github.com/users/#{GITHUB_USERNAME}/repos"

# Fetch repositories from GitHub
uri = URI(GITHUB_API_URL)
response = Net::HTTP.get(uri)
repositories = JSON.parse(response)

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
  readme_response = Net::HTTP.get(readme_uri)

  # Check if the response contains README data or an error message
  begin
    readme = JSON.parse(readme_response)
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
    puts `git push https://#{ENV['GH_TOKEN']}@github.com/#{GITHUB_USERNAME}/TheManWhoLikesToCode.github.io.git`
  end
end
