require 'spec_helper'

describe 'guest users' do
  before :each do
    app_setup
  end

  context 'when enabled' do
    before :each do
      # set relevant setting
    end

    describe 'visiting protected route' do
      context '/reservations/new' do
        it_behaves_like('inaccessible to guests', :new_reservation_path)
      end
      context '/reservations' do
        it_behaves_like('inaccessible to guests', :reservations_path)
      end
      context '/users' do
        it_behaves_like('inaccessible to guests', :users_path)
      end
      context '/app_configs/edit' do
        it_behaves_like('inaccessible to guests', :edit_app_configs_path)
      end
    end

    describe 'visiting permitted route' do
      context '/' do
        it_behaves_like('accessible to guests', :root_path)
      end
      context '/catalog' do
        it_behaves_like('accessible to guests', :catalog_path)
      end
      context '/equipment_models/:id' do
        it_behaves_like('accessible to guests',
          :equipment_model_path,
          EquipmentModel)
      end
      context '/categories/:id/equipment_models' do
        it_behaves_like('accessible to guests',
          :category_equipment_models_path,
          Category)
      end
    end
  end

  context 'when disabled' do
    before :each do
      # set relevant setting
    end
  end
end