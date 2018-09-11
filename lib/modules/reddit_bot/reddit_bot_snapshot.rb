module RedditBot
  class RedditBotSnapshot
    def initialize
      snaphotter = nil
      begin
        return unless Setting.only_row.is_running
        Rails.logger.info "RedditBotSnapshot Starting Run"

        client_id = Rails.application.credentials.reddit[:client_id]
        secret = Rails.application.credentials.reddit[:secret]
        user_name = Rails.application.credentials.reddit[:user_name]
        password = Rails.application.credentials.reddit[:password]
        reddit = Redd.it(
            user_agent: 'Redd:StopFascism:v0.0.2',
            client_id: client_id,
            secret: secret,
            username: user_name,
            password: password
        )

        archive_command = Setting.only_row.archiver_program
        snaphotter = ChromeManager.new

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

            template = Setting.only_row.template
            raise "template is empty" if template.to_s.strip.blank?

            #archive it based on preference
            if archive_command === 'imgur'
              snapshot_path = snaphotter.snapshot(url: url)
              imgur_session = Imgurapi::Session.instance(
                  client_id: Rails.application.credentials.dig(:imgur, :client_secret),
                  client_secret: Rails.application.credentials.dig(:imgur, :client_id),
                  refresh_token: Rails.application.credentials.dig(:imgur, :refresh_token),
                  access_token: Rails.application.credentials.dig(:imgur, :access_token)
              )

              imgur_response =imgur_session.image.image_upload(snapshot_path)

              archive_link = imgur_response.link

            else
              archive_link = `#{archive_command} #{url}`
              archive_link.to_s&.strip!
              raise "cannot find archive link" if archive_link.blank?
              raise "could not get the archive link for #{url}" unless $?.exitstatus === 0
            end



            reddit_response = nil
            template.gsub!("[[archive_url]]",archive_link)
            unless  Setting.only_row.dry_run
              reddit_response =  post.reply(template)
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

          end # each post
         end #each sub-reddit
      rescue => e
        Rails.logger.fatal "[Reddit Bot Snapshot]  \n" + e.to_s + "\n" + e.backtrace.join("\n")
      ensure
        snaphotter.clean_up unless snaphotter.blank? #close driver when exiting
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