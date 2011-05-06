# Add lib directory to load path so that statements like require 'artist' work.
$: << File.expand_path(File.dirname(__FILE__)) + '/lib'

require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'sqlite3'
require 'yaml'
require 'logger'

require 'mp3info'
require 'tempfile'
require 'media_type'
require 'media_location'
require 'artist'
require 'album'
require 'track'

namespace :fake_data do
  desc 'Loads the config file into an instance variable to be used by other tasks'
  task :load_config do
    @config = YAML::load_file('config/config.yml')
  end

  namespace :db do 
    desc 'Migrate the database using scripts in db/migrate.'
    task :migrate do
      ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
    end


    desc 'Deletes ALL existing records and then rebuilds and populates database with fake data.'
    task :populate => ['fake_data:load_config', :delete_data, :update_all] do
    end

    desc 'Updates the database with new fake data'
    task :update_all => [:update_media_locations, :update_music, :update_video]  do
    end

    desc 'Adds any new media locations specified in the configuration file.'
    task :update_media_locations => ['fake_data:load_config'] do
      media_type_music = MediaType.find_by_name('Music')
      @config['music_dirs'].each do |directory|
        media_type_music.media_locations.find_or_create_by_directory(directory)
      end
    end

    desc 'Scans for new music files and adds them to the database. Existing records are updated.'
    task :update_music do
      modified_epoch = Track.last_modified
      MediaType.find_by_name('Music').media_locations.each { |location| find_new_music_files(location.directory, modified_epoch) }
    end

    desc 'Scans for new video files and adds them to the database. Existing records are updated.'
    task :update_video do
      puts 'TODO update_video task'
    end

    desc 'Deletes ALL the data in the database.'
    task :delete_data do
      puts 'Deleting data...'
      Artist.delete_all
      Album.delete_all
      Track.delete_all
      MediaLocation.delete_all
    end
  end

private
  @artist_cache = {}
  @album_cache = {}
  @artist_album_cache = {}

	def find_new_music_files(directory, modified_epoch)
		files = find_files_modified_after(directory,"*.mp3", modified_epoch)
		if(files.size > 0) then add_new_music_files(files) else puts "No new music files found." end
    delete_orphaned_tracks()
    delete_orphaned_albums()
    delete_orphaned_artists()
	end

	def add_new_music_files(files)		
    num_files = files.size
		puts "Adding #{num_files} music files."
		files.each_with_index do |filename, number|
      tags = Mp3Info.open(filename, :encoding => 'utf-8').tag
      artist = get_artist(tags.artist)
      album = get_album(artist,File.dirname(filename),tags.album)
      if !artist.nil? && !album.nil? then
        track = Track.find_or_initialize_by_uri(:uri => filename,
          :title => tags.title,
          :track_number => tags.tracknum,
          :genre => tags.genre_s,
          :year => tags.year,
          :artist_id => artist.id,
          :album_id => album.id,
          :modify_date => File.mtime(filename).to_i
        )
        if ! track.save then
          puts "Unable to save information for track #{filename}"
          track.errors.each { | field, reason | puts "#{field} #{reason}"}
        else
          puts "[#{number+1} of #{num_files}] Saved track #{track.title}"
        end        
      end
    end
    puts 'Finished.'
	end

  def get_artist(name)
    unless @artist_cache[name]
      artist = Artist.find_or_initialize_by_name(name)
      if ! artist.save then
        puts "Unable to save information for the artist #{name}"
        artist.errors.each { | field, reason | puts "#{field} #{reason}" }
      else
        puts "Saved artist #{name}"
      end
      @artist_cache[name] = artist
    end
    @artist_cache[name]
  end

  def get_album(artist, uri, name)
    return nil if artist.nil?

    album = @album_cache[uri]

    unless album
      album = Album.find_or_initialize_by_uri(:uri => uri,
        :name => name
      )
      if ! album.save then
        puts "Unable to save information for the album #{name} : #{uri}"
        album.errors.each { | field, reason | puts "#{field} #{reason}" }
      else
        puts "Saved album #{name}"
      end
      @album_cache[uri] = album
    end

    @artist_album_cache[artist.id] ||= []
    unless @artist_album_cache[artist.id].include?(album.id)
      @artist_album_cache[artist.id] << album.id
      artist.albums << album
    end

    album
  end

  def delete_orphaned_tracks()
    puts "Deleting orphaned tracks"
    # Build an array with the ids of tracks whos files no longer exists.
    ids = Track.all.collect { |track| FileTest.exists?(track.uri) ? nil : track.id}.compact
    Track.delete(ids) unless ids.size == 0
  end

  def  delete_orphaned_albums()
    puts "Deleting orphaned albums"
    # Build an array with the ids of albums who no longer have any tracks.
    ids = Album.all.collect { |album| album.tracks.size > 0 ? nil : album.id}.compact
    Album.delete(ids) unless ids.size == 0
  end

  def  delete_orphaned_artists()
    puts "Deleting orphaned artist"
    # Build an array with the ids of artis who no longer have any albums.
    ids = Artist.all.collect { |artist| artist.albums.size > 0 ? nil : artist.id}.compact
    Artist.delete(ids) unless ids.size == 0
  end

	def find_files_modified_after(directory, pattern, modified_epoch)
		puts "Scanning in #{directory}"
		files = []
    begin
  		Tempfile.open("fake_data") do |temp|
  			File.utime(modified_epoch,modified_epoch,temp.path)
  			cmd = "find \"#{directory}\" -type f -newer \"#{temp.path}\" -iname \"#{pattern}\" -print"
  			files = `#{cmd}`.split("\n").collect { |file| File.expand_path(file) }
  		end
    rescue
    end
		files
	end
end
