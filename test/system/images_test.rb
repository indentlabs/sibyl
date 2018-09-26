require "application_system_test_case"

class ImagesTest < ApplicationSystemTestCase
  setup do
    @image = images(:one)
  end

  test "visiting the index" do
    visit images_url
    assert_selector "h1", text: "Images"
  end

  test "creating a Image" do
    visit images_url
    click_on "New Image"

    fill_in "Author", with: @image.author
    fill_in "Bucket", with: @image.bucket
    fill_in "Description", with: @image.description
    fill_in "Filename", with: @image.filename
    fill_in "License", with: @image.license
    fill_in "Source Url", with: @image.source_url
    fill_in "Title", with: @image.title
    click_on "Create Image"

    assert_text "Image was successfully created"
    click_on "Back"
  end

  test "updating a Image" do
    visit images_url
    click_on "Edit", match: :first

    fill_in "Author", with: @image.author
    fill_in "Bucket", with: @image.bucket
    fill_in "Description", with: @image.description
    fill_in "Filename", with: @image.filename
    fill_in "License", with: @image.license
    fill_in "Source Url", with: @image.source_url
    fill_in "Title", with: @image.title
    click_on "Update Image"

    assert_text "Image was successfully updated"
    click_on "Back"
  end

  test "destroying a Image" do
    visit images_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Image was successfully destroyed"
  end
end
