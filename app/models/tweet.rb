require 'twitter'

class Tweet < ActiveRecord::Base
  # Tweet cannot exceed 140 characters

  TWEET_TEMP_TWEET_ID = 999

  def self.send_tweet_and_save(tweet)
    self.get_client.update tweet.message

    # Set a temporary tweet id to be replaced on subsequent tweet get
    tweet.tweet_id = TWEET_TEMP_TWEET_ID
    tweet.save
  end

  def self.get_client
    @@client ||= Twitter::REST::Client.new do |config|
      config.consumer_key =         ENV["OMNIAUTH_PROVIDER_KEY"]
      config.consumer_secret =      ENV["OMNIAUTH_PROVIDER_SECRET"]
      config.access_token =         ENV["OMNIAUTH_ACCESS_TOKEN"]
      config.access_token_secret =  ENV["OMNIAUTH_ACCESS_TOKEN_SECRET"]
    end

    @@client
  end

  def self.retrieve_all_tweets
    # TODO - grab username from User object
    tweets = self.get_client.user_timeline('skarmali')

    # We now want to persist tweet if it does not exist in database
    tweets.each do |tweet|
      twitter_tweet = Tweet.find_by(:tweet_id => tweet.id)
      if (twitter_tweet.nil?)
        # See if there is a db record with invalid tweet_id
        update_tweet = Tweet.find_by(:message => tweet.full_text, :tweet_id => TWEET_TEMP_TWEET_ID)
        if (update_tweet.nil?)
          new_tweet = Tweet.new(:message => tweet.full_text, :tweet_id => tweet.id)
          new_tweet.save
        else
          update_tweet.update_attributes(:tweet_id => tweet.id)
          update_tweet.save
        end
      end
    end

    tweets
  end
end
