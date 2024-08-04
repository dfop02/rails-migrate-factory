module Support
  def migration_menus
    '
      class CreateMenus < ActiveRecord::Migration
        def change
          create_table :menus do |t|
            t.string  :name
            t.integer :parent_id
            t.boolean :inactive
            t.boolean :landing_page_menu, default: false
            t.integer :landing_page_id
            t.integer :position
            t.boolean :hidden
            t.string  :importer_name
            t.timestamps
          end

          add_index :menus, :parent_id
          add_index :menus, :name
        end
      end
    '
  end

  def migration_offers
    '
      class CreateOffers < ActiveRecord::Migration[7.0]
        def change
          create_table(:offers) do |t|
            t.string :name, null: false
            t.string :slug
            t.boolean :active, default: true, null: false
            t.text :description
            t.integer :product_id
            t.string :product_sku
            t.integer :offer_banner_id
            t.boolean :super_offer, default: false, null: false
            t.boolean :free_shipping, default: false, null: false
            t.text :specifications
            t.string :kind, limit: 32
            t.boolean :newer, default: false, null: false
            t.boolean :most_searched, default: false, null: false
            t.integer :frontend_position, default: 1
            t.boolean :featured, default: false, null: false
            t.integer :priority
            t.timestamps
          end
        end
      end
    '
  end

  def offers_add_blackfriday_column
    '
      class AddBlackfridayToOffers < ActiveRecord::Migration[7.0]
        def change
          add_column :offers, :blackfriday, :boolean, default: false
        end
      end
    '
  end

  def offers_remove_blackfriday_column
    '
      class RemoveBlackfridayToOffers < ActiveRecord::Migration[7.0]
        def change
          remove_column :offers, :blackfriday, :boolean
        end
      end
    '
  end

  def offers_rebuilded
    '
      class CreateOffers < ActiveRecord::Migration[7.0]
        def change
          create_table(:offers) do |t|
            t.string :name, null: false
            t.string :slug
            t.boolean :active, default: true, null: false
            t.text :description
            t.integer :product_id
            t.string :product_sku
            t.integer :offer_banner_id
            t.boolean :super_offer, default: false, null: false
            t.boolean :free_shipping, default: false, null: false
            t.text :specifications
            t.string :kind, limit: 32
            t.boolean :newer, default: false, null: false
            t.boolean :most_searched, default: false, null: false
            t.integer :frontend_position, default: 1
            t.boolean :featured, default: false, null: false
            t.integer :priority
            t.timestamps
            t.boolean :blackfriday, default: false
          end
        end
      end
    '
  end
end
