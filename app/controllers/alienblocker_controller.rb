require 'encrypted_strings'

class AlienblockerController < ApplicationController
  def index
    # generate a random body of text for the user to process
    file = Dir.glob(Dir.pwd + '/app/texts/*').sample # open a random file
    # read file contents and combine in to one string. get rid of all newlines and extra spaces
    @question = File.open(file).readlines.join(' ').gsub("\n",'').gsub(/\s+/, ' ').strip
    
    # generate a list of random words that the user has to ignore
    words = @question.downcase.gsub(/[^a-z0-9\s]/i, '').split(' ')
    unique_words = words.uniq # gsub is to remove puncuation
    # change the number of words we ask to exclude
    case unique_words.size
    when 0,1
      num_samples = 0
    when 2,3
      num_samples = 1
    else
      num_samples = 3
    end
    @ignore = unique_words.sample(num_samples)

    # figure out the answer
    word_counts = {} # key is word, value is count
    (unique_words - @ignore).each do |word|
      word_counts[word] = words.count(word)
    end
    @answer = Marshal.dump(word_counts).encrypt(:symmetric, :algorithm => 'des-ecb', :password => Rails.application.secrets.secret_base_key.to_s)
  end

  def process_input
    @user_input = params[:user_input]
    @answer = params[:answer]
    @ignore = params[:ignore]
    @question = params[:question]
    
    # decrypt the answer
    decrypted_answer = Marshal.load(@answer.decrypt(:symmetric, :algorithm => 'des-ecb', :password => Rails.application.secrets.secret_base_key.to_s))
    
    # build a hash out of the user input and see if it's the same as the answer
    i=0
    user_word_counts = @user_input.downcase.gsub(/\s+/, '').split(',')
    user_word_counts_hash = {}
    @correct = true
    while(i+1 < user_word_counts.size) do
      word = user_word_counts[i]
      num = user_word_counts[i+1].to_i
      user_word_counts_hash[word] = num
      i += 2 
    end
    @correct = false if decrypted_answer != user_word_counts_hash
    if @correct
      render status: :ok
    else
      render status: :bad_request
    end
  end
end
