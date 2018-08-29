module RedditBot
  class RedditBotBasic
    def initialize
      client_id = Rails.application.credentials.reddit[:client_id]
      secret = Rails.application.credentials.reddit[:secret]
      user_name = Rails.application.credentials.reddit[:user_name]
      password = Rails.application.credentials.reddit[:password]
      reddit = Redd.it(
          user_agent: 'Redd:StopFascism:v0.0.1',
          client_id: client_id,
          secret: secret,
          username: user_name,
          password: password
      )

      archive_command = 'savepagenow'  # 'archiveis'

      #subreddit_names = ['stop_fascism_bottest','politics']
       subreddit_names = ['stop_fascism_bottest']
      subreddit_names.each do |subreddit_name|
        r_thing = reddit.subreddit(subreddit_name)
        new_posts = r_thing.new
        index = 0;
        new_posts.each do |post|
          title = post.title
          thumbnail = post.thumbnail
          url = post.url

          permalink = 'https://reddit.com' + post.permalink
          domain = post.domain
          puts "#{title} #{thumbnail} #{url} #{permalink} #{domain}"

          if index === 0
              archive_link = `#{archive_command} #{url}`
              if $?.exitstatus === 0
                post.reply("An archived version of this will be at  #{archive_link}")
              end

          end
          index += 1

        end
      end




    end
  end
end

__END__

# half baked comment thing
# basically the comment can be a regular comment or an expanded comment,
 and each child of an expanded comment can be either
 so build up an array of comments while iterating though any children

          comments = post.comments
          comments.each_with_index do |comment, i|
            # comment_array = []
            # comment_house = comment
            # while  comment_house.is_a?(Redd::Models::MoreComments)
            #
            # end
            if comment.is_a?(Redd::Models::MoreComments)
              expanded_comments = comment.recursive_expand(link: post)
              expanded_comments.each_with_index do |x_comment,i|
                puts x_comment.inspect
              end
            else
              puts comment.body
              puts "[Score: '#{comment.score}' By: '#{comment.author.name}']"
            end
          end