require 'rails_helper'

RSpec.describe "Example", type: :system, js: true do
  it "submit's the form to request the next generation" do
    visit '/1' # set first cell to be alive

    within 'form#game' do
      expect(page.find(:css, 'button.cell', match: :first)[:'data-state']).to eq('1')

      click_button('Next Generation')
      expect(page).to have_content('Reset') # wait for ajax to return

      expect(page.find(:css, 'button.cell', match: :first)[:'data-state']).to eq('0')
    end
  end

  it 'toggles cell state on click' do
    visit root_path
    cell = page.find(:css, 'button.cell', match: :first)

    within 'form#game' do
      expect(cell[:'data-state']).to eq('0')
      cell.click
      expect(cell[:'data-state']).to eq('1')
    end
  end
end
