class CreateReportMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :report_mentions do |t|
      t.references :mentioning_report, foreign_key: { to_table: :reports }
      t.references :mentioned_report, foreign_key: { to_table: :reports }

      t.timestamps
      t.index [:mentioning_report_id, :mentioned_report_id], unique: true, name: :index_on_mentioning_report_id_and_mentioned_report_id
    end
  end
end
