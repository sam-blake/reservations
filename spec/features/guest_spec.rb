require 'spec_helper'

describe 'guest users' do
  before :each do
    app_setup
  end

  shared_examples 'unauthorized' do
    context 'visiting protected route' do
      describe '/reservations/new' do
        it_behaves_like('inaccessible to guests', :new_reservation_path)
      end
      describe '/reservations' do
        it_behaves_like('inaccessible to guests', :reservations_path)
      end
      describe '/users' do
        it_behaves_like('inaccessible to guests', :users_path)
      end
      describe '/app_configs/edit' do
        it_behaves_like('inaccessible to guests', :edit_app_configs_path)
      end
    end
  end

  context 'when enabled' do
    before :each do
      # set relevant setting
    end

    it_behaves_like 'unauthorized'

    context 'visiting permitted route' do
      describe '/' do
        it_behaves_like('accessible to guests', :root_path)
      end
      describe '/catalog' do
        it_behaves_like('accessible to guests', :catalog_path)
      end
      describe '/equipment_models/:id' do
        it_behaves_like('accessible to guests',
          :equipment_model_path,
          EquipmentModel)
      end
      describe '/categories/:id/equipment_models' do
        it_behaves_like('accessible to guests',
          :category_equipment_models_path,
          Category)
      end
    end

    describe 'can use the catalog' do
      before :each do
        visit '/'
        within(:css, "#add_to_cart_#{EquipmentModel.first.id}") do
          click_link "Add to Cart"
        end
        visit '/'
      end

      it 'can add items to cart' do
        expect(page.find(:css, '#list_items_in_cart')).to have_link(
          EquipmentModel.first.name,
          href: equipment_model_path(EquipmentModel.first))
      end

      it 'can remove items from cart' do
          click_link "Remove",
            href: "/remove_from_cart/#{EquipmentModel.first.id}"
          visit '/'
          expect(page.find(:css, '#list_items_in_cart')).not_to have_link(
            EquipmentModel.first.name,
            href: equipment_model_path(EquipmentModel.first))
      end

      # change the dates --> not sure how since we use JS for that. We can,
      # however, check that the equipment model divs display the correct dates
      # once we figure out how to change them via Capybara
    end
  end

  context 'when disabled' do
    before :each do
      # set relevant setting
    end

    it_behaves_like 'unauthorized'

  end
end