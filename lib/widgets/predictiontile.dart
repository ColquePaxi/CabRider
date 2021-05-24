import 'package:cab_rider/datamodels/address.dart';
import 'package:cab_rider/datamodels/prediction.dart';
import 'package:cab_rider/dataproviders/appdata.dart';
import 'package:cab_rider/helpers/requesthelper.dart';
import 'package:cab_rider/secrets/globalvariables.dart';
import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import '../brand_colors.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeId, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please waiting...'),
    );

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeId;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      // Para usar o conext aqui, tem que receber o BuildContext no método
      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);

      print(thisPlace.placeName);

      // Retorna para a tela anterior, porém passa essa string como RETORNO
      // para ser usada na pagina que a chamou a fim de servir como um
      // GATILHO para alguma outra ação no retorno.
      // mainpage.dart usa esse retorno para chamar um método contido em
      // mainpage.dart após o retorno da predictiontile.dart
      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        getPlaceDetails(prediction.placeId, context);
      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(OMIcons.locationOn, color: BrandColors.colorDimText),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(prediction.mainText,
                          overflow:
                              TextOverflow.ellipsis, // preenche com retic?ncias
                          maxLines: 1,
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 2),
                      Text(prediction.secondaryText,
                          overflow:
                              TextOverflow.ellipsis, // preenche com retic?ncias
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12, color: BrandColors.colorDimText)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
