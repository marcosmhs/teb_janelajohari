// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/admin_area/admin_area_invalid_access_screen.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text_controller.dart';
import 'package:teb_janelajohari/admin_area/user/user.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/teb_package.dart';

class SiteTextForm extends StatefulWidget {
  const SiteTextForm({super.key});

  @override
  State<SiteTextForm> createState() => _SiteTextFormState();
}

class _SiteTextFormState extends State<SiteTextForm> {
  final _formKey = GlobalKey<FormState>();
  var _initializing = true;
  var _saveingData = false;
  var _user = User();
  final List<SiteText> _siteTextList = [];
  final List<String> _pagesList = [];
  var _dropdownValue = '';

  void _addSiteTextList() {
    _siteTextList.add(SiteText(page: _dropdownValue != 'Selecione uma página' ? _dropdownValue : ''));

    _siteTextList.sort((a, b) {
      if (a.id.isEmpty && b.id.isNotEmpty) return -1;
      if (a.id.isNotEmpty && b.id.isEmpty) return 1;
      return 0;
    });
    setState(() {});
  }

  void _setExperienceToRemove({required SiteText siteText}) {
    TebCustomDialog(context: context).confirmationDialog(message: 'Excluir este texto?').then((value) {
      if (value == true) {
        if (siteText.id.isEmpty) {
          setState(() => _siteTextList.remove(siteText));
        } else {
          setState(() => siteText.setToRemove());
        }
      }
    });
  }

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var siteTextController = SiteTextController();
      TebCustomReturn retorno;
      try {
        retorno = await siteTextController.save(siteTextList: _siteTextList);

        if (retorno.returnType == TebReturnType.sucess) {
          TebCustomMessage.sucess(context, message: 'Dados alterados com sucesso');
          Navigator.of(context).pushReplacementNamed(Routes.adminAreaScreen, arguments: {'user': _user});
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebCustomMessage.error(context, message: retorno.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  void _fontColor({required SiteText siteText}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma cor'),
          content: MaterialPicker(
            pickerColor: siteText.color,
            onColorChanged: (selectecColor) {
              setState(() {
                siteText.color = selectecColor;
                siteText.setUpdated;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  String? _textEditValidator(String? value, String errorMessage) {
    var finalValue = value ?? '';
    if (finalValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  Widget _siteTextItem({required SiteText siteText}) {
    final size = MediaQuery.of(context).size;

    final TextEditingController pageController = TextEditingController(text: siteText.page);
    final TextEditingController localController = TextEditingController(text: siteText.local);
    final TextEditingController textController = TextEditingController(text: siteText.text);
    final TextEditingController sizeController = TextEditingController(text: siteText.size.toString());

    final TextEditingController paddingLeftController = TextEditingController(text: siteText.paddingLeft.toString());
    final TextEditingController paddingRightController = TextEditingController(text: siteText.paddingRight.toString());
    final TextEditingController paddingTopController = TextEditingController(text: siteText.paddingTop.toString());
    final TextEditingController paddingBottonController = TextEditingController(text: siteText.paddingBotton.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // text info
          SizedBox(
            width: size.width * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TebTextEdit(
                      width: size.width * 0.35,
                      labelText: 'Página (código)',
                      controller: pageController,
                      keyboardType: TextInputType.text,
                      onSave: (value) {
                        setState(() {
                          siteText.page = value ?? '';
                          siteText.setUpdated();
                        });
                      },
                      onChanged: (value) {
                        siteText.page = value ?? '';
                        siteText.setUpdated();
                      },
                      validator: (value) => _textEditValidator(value, 'Informe a página'),
                    ),
                    const Spacer(),
                    TebTextEdit(
                      width: size.width * 0.35,
                      labelText: 'Local (código)',
                      controller: localController,
                      onSave: (value) {
                        siteText.local = value ?? '';
                        siteText.setUpdated();
                      },
                      onChanged: (value) {
                        siteText.local = value ?? '';
                        siteText.setUpdated();
                      },
                      validator: (value) => _textEditValidator(value, 'Informe o local'),
                    ),
                  ],
                ),
                TebTextEdit(
                  labelText: 'Texto',
                  controller: textController,
                  maxLines: 4,
                  onSave: (value) {
                    siteText.text = value ?? '';
                    siteText.setUpdated();
                  },
                  onChanged: (value) {
                    siteText.text = value ?? '';
                    siteText.setUpdated();
                  },

                  validator: (value) => _textEditValidator(value, 'Informe o texto'),
                ),

                Row(
                  children: [
                    TebTextEdit(
                      width: size.width * 0.25,
                      labelText: 'Tamanho',
                      controller: sizeController,
                      onSave: (value) {
                        siteText.size = double.tryParse(value ?? '') ?? 0;
                        siteText.setUpdated();
                      },
                      onChanged: (value) {
                        siteText.size = double.tryParse(value ?? '') ?? 0;
                        siteText.setUpdated();
                      },
                      validator: (value) => _textEditValidator(value, 'Informe o tamanho'),
                    ),
                    TebButton(
                      label: 'Selecionar cor',
                      onPressed: () => _fontColor(siteText: siteText),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    Expanded(
                      child: TebCheckBox(
                        context: context,
                        value: siteText.bold,
                        title: 'Negrito',
                        onChanged: (value) => setState(() => siteText.bold = value ?? false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TebText('Padding', textSize: 20, padding: EdgeInsets.only(bottom: 10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TebTextEdit(
                      width: 160,
                      labelText: 'Left',
                      controller: paddingLeftController,
                      padding: EdgeInsets.only(right: 10),
                      onSave: (value) {
                        setState(() {
                          siteText.paddingLeft = double.tryParse((value ?? '')) ?? 0.0;
                          siteText.setUpdated();
                        });
                      },
                      onChanged: (value) {
                        siteText.paddingLeft = double.tryParse((value ?? '')) ?? 0.0;
                        siteText.setUpdated();
                      },
                    ),
                    TebTextEdit(
                      width: 160,
                      labelText: 'Right',
                      controller: paddingRightController,
                      padding: EdgeInsets.only(right: 10),
                      onSave: (value) {
                        setState(() {
                          siteText.paddingRight = double.tryParse((value ?? '')) ?? 0.0;
                          siteText.setUpdated();
                        });
                      },
                      onChanged: (value) {
                        siteText.paddingRight = double.tryParse((value ?? '')) ?? 0.0;
                        siteText.setUpdated();
                      },
                    ),
                    TebTextEdit(
                      width: 160,
                      labelText: 'Top',
                      controller: paddingTopController,
                      padding: EdgeInsets.only(right: 10),
                      onSave: (value) {
                        setState(() {
                          siteText.paddingTop = double.tryParse((value ?? '')) ?? 0.0;
                          siteText.setUpdated();
                        });
                      },
                      onChanged: (value) {
                        siteText.paddingTop = double.tryParse((value ?? '')) ?? 0.0;
                        siteText.setUpdated();
                      },
                    ),
                    TebTextEdit(
                      width: 160,
                      labelText: 'Botton',
                      controller: paddingBottonController,
                      padding: EdgeInsets.only(right: 10),
                      onSave: (value) {
                        setState(() {
                          siteText.paddingBotton = double.tryParse((value ?? '')) ?? 0.0;
                          siteText.setUpdated();
                        });
                      },
                      onChanged: (value) {
                        siteText.paddingBotton = double.tryParse((value ?? '')) ?? 0.0;
                        siteText.setUpdated();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              TebText('Preview', padding: EdgeInsets.only(right: 20)),
                              TebButton(
                                icon: Icon(Icons.refresh),
                                buttonType: TebButtonType.outlinedButton,
                                onPressed: () => setState(() {}),
                              ),
                              if (siteText.color.toARGB32() == 4294967295)
                                TebText(
                                  'Cor de fundo preta para permitir visualização do texto branco',
                                  padding: EdgeInsets.only(left: 10),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Html(
                        data:
                            '${siteText.color.toARGB32() == 4294967295 ? '<span style="background-color: black">' : ''} ${siteText.html} ${siteText.color.toARGB32() == 4294967295 ? '</span>' : ''}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(height: 2.50, color: Colors.black87),
                const SizedBox(height: 40),
              ],
            ),
          ),
          // remove option
          SizedBox(
            //width: size.width * 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebButton(
                  label: 'Remover',
                  onPressed: () => _setExperienceToRemove(siteText: siteText),
                  enabled: siteText.status != SiteTextStatus.delete,
                  padding: EdgeInsets.only(top: 20),
                ),
                if (siteText.status == SiteTextStatus.created) const TebText('Novo', padding: EdgeInsets.all(8)),
                if (siteText.status == SiteTextStatus.updated) const TebText('Alterado', padding: EdgeInsets.all(8)),
                if (siteText.status == SiteTextStatus.delete) const TebText('Marcado para exclusão', padding: EdgeInsets.all(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageFilterDropDownButton() {
    if (_pagesList.isEmpty) {
      return TebText('Carregando...');
    }

    return DropdownButton(
      value: _dropdownValue,
      focusColor: Theme.of(context).canvasColor,
      icon: Icon(FontAwesomeIcons.anglesDown, color: Colors.black),

      //iconSize: 42,
      onChanged: (String? value) {
        if ((value ?? '').isNotEmpty) {
          if (_siteTextList.where((e) => e.status != SiteTextStatus.saved).isEmpty) {
            _changePageFilterDropDownButtonValue(page: value ?? '');
          } else {
            TebCustomDialog(context: context)
                .confirmationDialog(message: 'Mudar o filtro fará com que todas as alterações sejam perdidas, deseja continuar')
                .then((anser) {
                  if (anser ?? false) _changePageFilterDropDownButtonValue(page: value ?? '');
                });
          }
        }
      },
      items:
          _pagesList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: TebText(value));
          }).toList(),
    );
  }

  void _changePageFilterDropDownButtonValue({required String page, String local = ''}) {
    if (page == 'Selecione uma página') {
      setState(() {
        _dropdownValue = page;
        _siteTextList.clear();
      });
    } else {
      setState(() {
        _dropdownValue = page;
        SiteTextController.getSiteTextList(page: page).then((siteTextListLocal) {
          setState(() {
            _siteTextList.clear();
            _siteTextList.addAll(siteTextListLocal.where((s) => local.isEmpty || s.local.contains(local)));
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();

      SiteTextController.getSiteTextPageList().then((pageList) {
        _pagesList.clear();
        _pagesList.add('Selecione uma página');
        if (pageList.isEmpty) _pagesList.add('');
        setState(() {
          _pagesList.addAll(pageList);
          _dropdownValue = _pagesList.first;
        });
      });
      _initializing = false;
    }

    final Size size = MediaQuery.of(context).size;

    if (_user.id.isEmpty) {
      return AdminAreaInvalidAccessScreen();
    }

    return TebCustomScaffold(
      title: Text('Textos'),
      responsive: false,
      fixedWidth: MediaQuery.of(context).size.width * 0.9,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // intro text title
            TebButtonsLine(
              mainAxisAlignment: MainAxisAlignment.end,
              padding: const EdgeInsets.symmetric(vertical: 10),
              buttons: [
                _pageFilterDropDownButton(),
                TebTextEdit(
                  labelText: 'Local',
                  width: 250,
                  onChanged: (value) {
                    if ((value ?? '').isNotEmpty) {
                      _changePageFilterDropDownButtonValue(page: _siteTextList.first.page, local: value!);
                    }
                  },
                ),
                const Spacer(),
                TebButton(label: 'Adicionar novo texto', onPressed: () => _addSiteTextList()),
                TebButton(
                  label: 'Cancelar',
                  buttonType: TebButtonType.outlinedButton,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TebButton(label: 'Salvar', onPressed: () => _submit()),
              ],
            ),
            SizedBox(
              height: size.height * 0.85,
              width: size.width * 0.88,
              child:
                  _siteTextList.isEmpty
                      ? TebText('Selecione uma página ou inicie um novo texto')
                      : ListView.builder(
                        itemCount: _siteTextList.length,
                        itemBuilder: (itemBuildercontext, index) {
                          return _siteTextItem(siteText: _siteTextList[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
