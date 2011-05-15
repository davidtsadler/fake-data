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

require 'digest/md5'
require 'csv'

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

  namespace :dropbox do
    desc 'Save album covers into dropbox directory'
    task :save_album_covers => 'fake_data:load_config' do
      dropbox_dir = create_dropbox_directory('album_covers')
      albums = Album.with_cover.all
      num_albums = albums.size
      albums.each_with_index do |album, number|
        puts "[#{number+1} of #{num_albums}] Saving album cover for '#{album.name}'"
        album.cover_url = save_album_cover(album, dropbox_dir)        
        album.save
      end
    end
  end

  namespace :export do
    namespace :powa do
      desc 'Export album information as a CSV file suitible for importing into a Powa store.'
      task :albums do
        directory = 'export/powa'
        create_directory(directory)
        csv = CSV.open(File.join(directory, 'albums.csv'), 'w+')
        Album.with_cover.order('name ASC').all.each do |album|
          csv << album.to_powa
        end
        csv.close
      end
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
        :name => name,
        :cover => get_album_cover(uri)
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

  def get_album_cover(directory)
    filename = directory + "/album.jpg"
    return nil if !FileTest.exists?(filename)
    File.read(filename) 
  end

  def delete_orphaned_tracks()
    puts "Deleting orphaned tracks"
    # Build an array with the ids of tracks who's files no longer exists.
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
    # Build an array with the ids of artist who no longer have any albums.
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

  def save_album_cover(album, directory) 
    save_dropbox_file(directory, Digest::MD5.hexdigest(album.uri) + ".jpg", album.cover)
  end

  def create_dropbox_directory(directory)
    dropbox_dir = File.join(@config['dropbox_path'], 'Public', directory)
    create_directory(dropbox_dir)
    dropbox_dir 
  end

  def save_dropbox_file(directory, filename, data)
    dir = File.join(directory, filename)
    file = File.open(dir, 'w+b')
    file.puts data
    file.close
    dropbox_public_link(dir)
  end

  def dropbox_public_link(directory)
    dir = File.dirname(directory)
    filename = File.basename(directory)
    dir.sub!("#{@config['dropbox_path']}\/Public", "http://dl.dropbox.com/u/#{@config['dropbox_user_id']}")
    File.join(dir, filename)
  end

  def create_directory(directory)
    `mkdir -p #{directory}` unless File.exists? directory
  end
end
