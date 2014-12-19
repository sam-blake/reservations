# based on http://www.tkalin.com/blog_posts/testing-authorization-using-rspec-parametrized-shared-examples/

shared_examples 'inaccessible to guests' do |url|
  let(:url_path) { send(url) }

  it 'redirects to the signin page with errors' do
    visit url_path
    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_selector('.alert-error')
  end
end

shared_examples 'accessible to guests' do |url|
  let(:url_path) { send(url) }

  it 'goes to the correct page with sign in link' do
    visit url_path
    expect(current_path).to eq(url_path)
    expect(page).to have_link('Sign In')
  end
end