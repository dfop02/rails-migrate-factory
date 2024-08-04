require 'spec_helper'

RSpec.describe MigrateFactoryRails do
  include Support

  describe 'Version' do
    it 'has a version number' do
      expect(MigrateFactoryRails::VERSION).not_to be_nil
    end
  end

  describe 'Factory' do
    let(:buffer) { StringIO.new }
    let(:filename) { 'rebuilded_table.rb' }

    before do
      allow(File).to receive(:open).with(filename, 'a+').and_yield(buffer)
      allow(Rails).to receive(:version).and_return('7.0')
    end

    context 'when Builder correctly' do
      it 'returns table name' do
        factory_service = MigrateFactoryRails::Factory.new(migration_menus)
        expect(factory_service.table_name).to eq('menus')
      end

      it 'add column from childrens' do
        factory_service = MigrateFactoryRails::Factory.new(migration_offers)
        expect(factory_service.table_name).to eq('offers')

        factory_service.collect_info_from_children_migrate_content(offers_add_blackfriday_column)
        File.open(filename, 'a+') { |f| factory_service.rebuild_file_migration(f) }
        expect(buffer.string.squish).to eq(offers_rebuilded.squish)
      end

      it 'add and remove column from childrens' do
        factory_service = MigrateFactoryRails::Factory.new(migration_offers)
        expect(factory_service.table_name).to eq('offers')

        factory_service.collect_info_from_children_migrate_content(offers_add_blackfriday_column)
        factory_service.collect_info_from_children_migrate_content(offers_remove_blackfriday_column)
        File.open(filename, 'a+') { |f| factory_service.rebuild_file_migration(f) }
        expect(buffer.string.squish).to eq(migration_offers.squish)
      end
    end
  end
end
