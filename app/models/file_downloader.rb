class FileDownloader
  def self.enqueue_download song_url, song_request
    if File.exist? "songs/#{song_request.file_id}.m4a"
      song_request.status = 'Downloaded'
      if ENV['autopilot'] == 'true'
        song_request.enqueue!
      else
        song_request.save!
      end
    else
      Thread.new do
        %x{mkdir -p songs && youtube-dl -o songs/#{song_request.file_id}.%\\(ext\\)s -x #{song_url}}
        if File.exist? "songs/#{song_request.file_id}.m4a"
          song_request.status = 'Downloaded'
          if ENV['autopilot'] == 'true'
            song_request.enqueue!
          end
        else
          song_request.status = 'Error'
        end
        song_request.save!
      end.run
    end
  end
end