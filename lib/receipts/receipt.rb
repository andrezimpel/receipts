require 'prawn'
require 'prawn/table'

module Receipts
  class Receipt < Prawn::Document
    attr_reader :attributes, :id, :company, :custom_font, :line_items, :logo, :message, :product, :subheading, :footer_columns

    def initialize(attributes)
      @attributes  = attributes
      @id          = attributes.fetch(:id)
      @company     = attributes.fetch(:company)
      @line_items  = attributes.fetch(:line_items)
      @custom_font = attributes.fetch(:font, {})
      @message     = attributes.fetch(:message) { default_message }
      @footer_columns     = attributes.fetch(:footer_columns)
      @subheading  = attributes.fetch(:subheading) { default_subheading }

      super(margin: 0)

      setup_fonts if custom_font.any?
      generate
    end

    private

      def default_message
        "We've received your payment for #{attributes.fetch(:product)}. You can keep this receipt for your records. For questions, contact us anytime at <color rgb='326d92'><link href='mailto:#{company.fetch(:email)}?subject=Charge ##{id}'><b>#{company.fetch(:email)}</b></link></color>."
      end

      def default_subheading
        "RECEIPT FOR CHARGE #%{id}"
      end
    
      def default_footer_message
        "RECEIPT FOR CHARGE #%{id}"
      end
    
      def default_logo_size
        32
      end

      def setup_fonts
        font_families.update "Primary" => custom_font
        font "Primary"
      end

      def generate
        bounding_box [0, 792], width: 612, height: 792 do
          bounding_box [85, 792], width: 442, height: 792 do
            header
            charge_details
            footer
          end
        end
      end

      def header
        logo_size = company.fetch(:logo_size, default_logo_size)
        move_down 60

        logo_path = company.fetch(:logo, '')

        if logo_path.empty?
          move_down logo_size
        else
          image open(logo_path), height: logo_size
        end

        move_down 8
        text "<color rgb='a6a6a6'>#{subheading % { id: id }}</color>", inline_format: true

        move_down 30
        text message, inline_format: true, size: 12.5, leading: 4
      end

      def charge_details
        move_down 30

        borders = line_items.length - 2

        table(line_items, cell_style: { border_color: 'cccccc', inline_format: true }) do
          cells.padding = 12
          cells.borders = []
          row(0..borders).borders = [:bottom]
        end
      end

      def footer
        move_down 45
        text company.fetch(:name), inline_format: true
        text "<color rgb='888888'>#{company.fetch(:address)}</color>", inline_format: true
        
        move_down 50
        font_size 7
        borders = line_items.length - 2

        if !footer_columns.empty?
          table(footer_columns, cell_style: { border_color: 'ffffff', inline_format: true }) do
            cells.padding = 0
            cells.borders = []
            row(0..borders).borders = [:bottom]
          end
        end
      end
  end
end
