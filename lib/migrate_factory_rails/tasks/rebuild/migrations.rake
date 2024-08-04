require 'migrate_factory_rails/factory'

namespace :rebuild do
  desc 'Rebuild your migrations for agilize setup'
  task :migrations, [:keep_last_n_migrations] => [:environment] do |_task, args|
    include MigrateFactoryRails

    args.with_defaults(keep_last_n_migrations: 5)

    rebuild_path = Rails.root.join('tmp/rebuild/')
    FileUtils.mkdir_p(rebuild_path)

    begin
      mgt_files = Dir.glob(Rails.root.join('db/migrate/*'))

      if args.keep_last_n_migrations > mgt_files.length
        invalid_text = "Invalid 'keep_last_n_migrations' options because your project has less than #{args.keep_last_n_migrations} migrations."
        abort invalid_text
      end

      mgt_total_files = mgt_files[0..-args.keep_last_n_migrations].length
      puts 'Starting rebuild migrations...'

      mgt_files.each_with_index do |migrate_file, index|
        factory_service = Factory.new(File.read(migrate_file))
        next if factory_service.table_name.blank?

        print "Working on #{factory_service.table_name} table..."
        File.open(Rails.root.join("tmp/rebuild/#{factory_service.table_name}.rb"), 'a+') do |f|
          mgt_files[index..-args.keep_last_n_migrations].each do |migrate_children|
            factory_service.collect_info_from_children_migrate_content(File.read(migrate_children))
          end

          factory_service.rebuild_file_migration(f)
        end

        print "Done!\n"
      end
    rescue StandardError
      @error = true
    ensure
      new_total_files = Dir.glob(Rails.root.join('tmp/rebuild/*')).length
      abort 'Something goes wrong and the script abort' if new_total_files.zero? || @error

      puts "\nStatistics:\n"
      puts "Ignoring last #{args.keep_last_n_migrations} migrations, we had #{mgt_total_files} migrates reduced to #{new_total_files} migrates."
      puts "Total #{((1-(new_total_files/mgt_total_files.to_f))*100).to_i}% reduction in migrations.."
    end
  end

  desc 'Cleanup rebuild tasks folder'
  task :cleanup do
    rebuild_path = Rails.root.join('tmp/rebuild/')
    print 'Cleaning...'
    rebuild_path.children.each(&:unlink) if rebuild_path.exist?
    print "Done!\n"
  end
end
