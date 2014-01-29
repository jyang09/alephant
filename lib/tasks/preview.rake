require 'alephant/preview/server'
require 'alephant/preview/template'

namespace :alephant do
  namespace :preview do
    task :go do
      Alephant::Preview::Server.run!
    end
    task :update do
      Alephant::Preview::Template.update(
        "#{Dir.pwd}/views/templates/preview.mustache"
      )
    end
  end
end

