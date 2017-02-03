class OwnershipsController < ApplicationController
  before_action :logged_in_user

  def create
    if params[:item_code]
      @item = Item.find_or_initialize_by(item_code: params[:item_code])
      # Itemモデルの中からitem_codeという値で検索して、存在する場合はそのデータを返し
    else
      @item = Item.find(params[:item_id])
      # 存在しない場合は、item_idという値で@itemに代入
    end

    # itemsテーブルに存在しない場合は楽天のデータを登録する。
    if @item.new_record?
      # TODO 商品情報の取得 RakutenWebService::Ichiba::Item.search を用いてください
      # 楽天APIを使ってitemCodeから商品コードと一致するものを検索する処理
      items = RakutenWebService::Ichiba::Item.search(itemCode: params[:item_code])
      # ownerships?item_code=okaidoku%3A10014442&amp;type=Want

      item                  = items.first
      @item.title           = item['itemName']
      @item.small_image     = item['smallImageUrls'].first['imageUrl']
      @item.medium_image    = item['mediumImageUrls'].first['imageUrl']
      @item.large_image     = item['mediumImageUrls'].first['imageUrl'].gsub('?_ex=128x128', '')
      @item.detail_page_url = item['itemUrl']
      @item.save!
    end

    # ownershipsテーブル
    # id | user_id:integer | item_id:integer | type:string
    # 1  |  1              | 1               | 'Have'
    # 2  |  1              | 1               | 'Want'
    
    # params[:type] <<<<< 'Have' か　もしくは 'Want'という文字
    # TODO ユーザにwant or haveを設定する
    if params[:type] == 'Have'
      current_user.have(@item)
    else
      current_user.want(@item)
    end
    # params[:type]の値にHaveボタンが押された時には「Have」,
    # Wantボタンが押された時には「Want」が設定されています。
    

  end

  def destroy
    @item = Item.find(params[:item_id])

    # TODO 紐付けの解除。 
    if params[:type] == "Have"
      current_user.unhave(@item)
    elsif params[:type] == "Want"
      current_user.unwant(@item)
    end
    # params[:type]の値にHave itボタンが押された時には「Have」,
    # Want itボタンが押された時には「Want」が設定されています。

  end
end
