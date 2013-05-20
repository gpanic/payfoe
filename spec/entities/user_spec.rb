require 'spec_helper'
=begin
describe User do

  before :each do
    @user = User.new(1, "username", "email", "name")
  end

  describe 'has an id property which' do

    it 'returns the correct id' do
      @user.id.should eql 1
    end

    it 'sets the id correctly' do
      @user.id = "id changed"
      @user.id.should eql "id changed"
    end

  end

  describe 'has a username property which' do

    it 'returns the correct username' do
      @user.username.should eql "username"
    end

    it 'sets the username correctly' do
      @user.username = "username changed"
      @user.username.should eql "username changed"
    end

  end

  describe 'has an email property' do

    it 'returns the correct email' do
      @user.email.should eql "email"
    end

    it 'sets the email correctly' do
      @user.email = "email changed"
      @user.email.should eql "email changed"
    end

  end

  describe 'has an email property' do

    it 'returns the correct email' do
      @user.email.should eql "email"
    end

    it 'sets the email correctly' do
      @user.email = "email changed"
      @user.email.should eql "email changed"
    end

  end

  describe 'has a name property' do

    it 'returns the correct name' do
      @user.name.should eql "name"
    end

    it 'sets the name correctly' do
      @user.name = "name changed"
      @user.name.should eql "name changed"
    end

  end

end
=end
