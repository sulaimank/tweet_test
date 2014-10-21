class TweetsController < ApplicationController
  before_action :set_tweets, only: [:index]
  before_action :set_twitter_tweets, only: [:index, :create]

  def index
    respond_to do |format|
      format.html
    end
  end

  def create
    @tweet = Tweet.create(:message => params[:message])

    respond_to do |format|
      if Tweet.send_tweet_and_save @tweet
        flash[:notice] = "Message tweeted at #{Time.now}"
        format.html { redirect_to tweets_path }
      else
        flash[:notice] = "Message failed to save."
        format.html { redirect_to tweets_path }
      end
    end
  end

  private

  def set_tweets
    @tweets = Tweet.all
  end

  def set_twitter_tweets
    @twitter_tweets = Tweet.retrieve_all_tweets
    @twitter_tweets = [] if @twitter_tweets.nil?
  end
end
