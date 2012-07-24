require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres://localhost:5432/coredata")

run Rack::CoreData('./Example.xcdatamodeld')

# Seed data if no records currently exist
if Rack::CoreData::Models::Artist.count == 0
  SONGS_BY_ARTIST = {
    "Ratatat"=> ["Shiller", "Falcon Jab", "Mi Viejo", "Mirando", "Flynn", "Bird-Priest", "Shempi", "Imperials", "Dura", "Brulee", "Mumtaz Khan", "Gipsy Threat", "Black Heroes"], 
    "Phoenix"=>["Lisztomania", "1901", "Fences", "Love Like A Sunset", "Lasso", "Rome", "Countdown (Sick For The Big Sun)", "Girlfriend", "Armistice"], 
    "Hot Chip"=>["Thieves In The Night", "Hand Me Down Your Love", "I Feel Better", "One Life Stand", "Brothers", "Slush", "Alley Cats", "We Have Love", "Keep Quiet", "Take It In"], 
    "Fleet Foxes"=>["Sun It Rises", "White Winter Hymnal", "Ragged Wood", "Tiger Mountain Peasant Song", "Quiet Houses", "He Doesnt Know Why", "Heard Them Stirring", "Your Protector", "Meadowlarks", "Blue Ridge Mountains", "Oliver James"], 
    "Grizzly Bear"=>["Southern Point", "Two Weeks", "All We Ask", "Fine For Now", "Cheerleader", "Dory", "Ready, Able", "About Face", "Hold Still", "While You Wait for the Others", "I live With You", "Foreground"], 
    "Cold War Kids"=>["Against Privacy", "Mexican Dogs", "Every Valley Is Not a Lake", "Something Is Not Right with Me", "Welcome to the Occupation", "Golden Gate Jumpers", "Avalanche in B", "I've Seen Enough", "Every Man I Fall For", "Dreams Old Men Dream", "On the Night My Love Broke Through", "Relief", "Cryptomnesia"], 
    "Two Door Cinema Club"=>["Cigarettes in the Theatre", "Come Back Home", "Do You Want It All", "This is the Life", "Something Good Can Work", "I Can Talk", "Undercover Martyn", "What You Know", "Eat That up, It's Good for You", "You're Not Stubborn"], 
    "Wild Beasts"=>["The Fun Powder Plot", "Hooting & Howling", "All The Kings Men", "When I'm Sleepy", "We Still Got The Taste Dancing On Our Tongues", "Two Dancers", "Two Dancers II", "This Is Our Lot", "Underbelly", "The Empty Nest"], 
    "Janelle Monae"=>["The March Of The Wolfmasters", "Violet Stars Happy Hunting!!!", "Many Moons", "Cybertronic Purgatory", "Sinceraly, Jane.", "Mr. President", "Smile"], 
    "Bibio"=>["Ambivalence Avenue", "Jealous Of Roses", "All The Flowers", "Fire Ant", "Haikuesque (When She Laughs)", "Sugarette", "Lovers Carvings", "Abrasion", "S'Vive", "The Palm Of Your Wave", "Cry ! Baby !", "Dwrcan"]
  }

  SONGS_BY_ARTIST.each do |artist, songs|
    artist = Rack::CoreData::Models::Artist.create(name: artist, artistDescription: "Lorem ipsum dolar sit amet")
    songs.each do |song|
      Rack::CoreData::Models::Song.create(artist: artist, title: song)
    end
  end
end
