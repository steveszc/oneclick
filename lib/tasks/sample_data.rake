namespace :oneclick do
  desc "Add Sample Data for configured brand."
  task :add_sample_data => :environment do
    case Oneclick::Application.config.brand
      when 'arc'
        puts 'Loading ARC Sample Data...'
        require File.join(Rails.root, 'db', 'arc/arc_sample_data.rb')
      when 'pa'
        puts 'Loading PA Sample Data...'
        require File.join(Rails.root, 'db', 'pa/pa_sample_data.rb')
      when 'broward'
        puts 'Loading Broward Sample Data...'
        require File.join(Rails.root, 'db', 'broward/broward_sample_data.rb')
      when 'jta'
        puts 'Currently no JTA Sample Data...'
        # require File.join(Rails.root, 'db', 'broward/broward_sample_data.rb')
      else
        puts 'UNKNOWN BRAND: ' + Oneclick::Application.config.brand.to_s
        return
    end

    puts 'Running sample data common to all providers...'
    require File.join(Rails.root, 'db', 'common_sample_data.rb')
    puts 'Finished running sample data common to all providers.'

  end

  desc "Update Attributes Per Installation."
  task :update_attributes => :environment do
    require File.join(Rails.root, 'db', Oneclick::Application.config.brand + '/update_attributes.rb')
  end

  desc "Update Origin/Destination to Endpoints/Coverages"
  task :create_endpoints_and_coverages => :environment do
    ServiceCoverageMap.all.each do |scm|
      case scm.rule
      when 'origin'
        scm.rule = 'endpoint_area'
      when  'destination'
        scm.rule = 'coverage_area'
      end
      scm.save
    end

    Service.all.each do  |service|
      service.build_polygons
    end

  end

  desc "Add Cities"
  task :add_cities => :environment do
    cities = []
    case Oneclick::Application.config.brand

      when 'broward'
        cities = ["Cooper City",
                  "Lauderdale Lakes",
                  "Miramar",
                  "Sunrise",
                  "Davie",
                  "Tamarac",
                  "Wilton Manors",
                  "Pompano Beach",
                  "Margate",
                  "Coral Springs",
                  "Coconut Creek",
                  "North Lauderdale",
                  "Lauderhill",
                  "Parkland",
                  "Miami",
                  "Fort Lauderdale",
                  "Miami Beach",
                  "Boca Raton"]

    end

    cities.each do |city|
      puts city
      GeoCoverage.where(value: city, coverage_type: 'city').first_or_create
    end

end


end
