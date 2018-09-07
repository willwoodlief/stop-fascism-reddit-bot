module RedditBot
  class RedditBotBasic
    def initialize
      return unless Setting.only_row.is_running
      Rails.logger.info "RedditBotBasic Starting Run"

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

     # archive_command = 'savepagenow'  # 'archiveis'
      archive_command = Setting.only_row.archiver_program
      Rails.logger.debug "archiver is " + archive_command.to_s
      return if archive_command.blank?

      #subreddit_names = ['stop_fascism_bottest','politics']
       subreddit_names =  Subreddit.pluck(:subreddit_name)
       Rails.logger.debug "subreddit names is " + archive_command.to_s
       subreddit_names.each do |subreddit_name|
        r_thing = reddit.subreddit(subreddit_name)
        new_posts = r_thing.new
        new_posts.each do |post|
          title = post.title
          thumbnail = post.thumbnail
          url = post.url

          permalink = 'https://reddit.com' + post.permalink
          domain = post.domain
          Rails.logger.debug "#{title} #{thumbnail} #{url} #{permalink} #{domain}"


          #check to see if the domain is on the black list
          next unless BadSite.listed(domain)
          next if Post.already_processed(permalink)

          archive_link = `#{archive_command} #{url}`
          archive_link.to_s&.strip!
          raise "cannot find archive link" if archive_link.blank?
          reddit_response = nil
          if $?.exitstatus === 0

            template = Setting.only_row.template
            raise "template is empty" if template.to_s.strip.blank?
            template.gsub!("[[archive_url]]",archive_link)
            unless  Setting.only_row.dry_run
              reddit_response =  post.reply(template)
            end
          else
            raise "could not get the archive link for #{url}"
          end


          post = Post.new
          post.thumbnail = thumbnail
          post.added_ts = Time.now.to_i
          post.title = title
          post.archive_url = archive_link
          post.op_url= url
          post.post_url = permalink
          post.subreddit = subreddit_name
          post.domain = domain
          post.bad_sites_id =  BadSite.get_id(url)
          post.is_dry_run = Setting.only_row.dry_run
          post.reddit_response= reddit_response.to_h.to_s
          post.save!

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