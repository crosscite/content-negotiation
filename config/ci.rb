CI.run do
  step "Setup", "bin/setup --skip-server"
  
  step "Style: Ruby", "bin/rubocop"
  
  step "Test: RSpec", "bundle exec rspec"

  step "Security: Brakeman", "bundle exec brakeman"

  step "Vulnerability: Bundler Audit", "bundle exec bundler-audit check --update"
end