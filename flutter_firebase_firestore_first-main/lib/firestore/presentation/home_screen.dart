import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_first/firestore_produtos/presentation/produto_screen.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class FirestoreAnalytics {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  incrementarAcessosTotais() {
    _incrementar("acessos_totais");
  }

  incrementarListasAdicionadas() {
    _incrementar("listas_adicionadas");
  }

  incrementarAtualizacoesManuais() {
    _incrementar("atualizacoes_manuais");
  }

  _incrementar(String field) async {
    // Pedir ao firestore a versão atual do documento "geral" na coleção "analytics"
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("analytics").doc("geral").get();

    // Inicializar um documento que representa nosso documento "geral"
    Map<String, dynamic> document = {};

    // Preencher nosso documento com os dados existentes (se eles existirem)
    if (snapshot.data() != null) {
      document = snapshot.data()!;
    }

    // Caso o campo que queremos somar tenha dados, somamos, se não inicializamos com o valor 1
    if (document[field] != null) {
      document[field] = document[field] + 1;
    } else {
      document[field] = 1;
    }

    // Atualizamos no Firestore
    firestore.collection("analytics").doc("geral").set(document);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirestoreAnalytics analytics = FirestoreAnalytics();

  @override
  void initState() {
    refresh();
    analytics.incrementarAcessosTotais();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listin - Feira Colaborativa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              children: List.generate(
                listListins.length,
                (index) {
                  Listin model = listListins[index];
                  return Dismissible(
                    key: ValueKey<Listin>(model),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                        padding: const EdgeInsets.only(left: 6),
                        alignment: Alignment.centerLeft,
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        )),
                    onDismissed: (direction) {
                      remove(model);
                    },
                    child: ListTile(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProdutoScreen(
                              listin: model,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        showFormModal(model: model);
                      },
                      leading: const Icon(Icons.list_alt_rounded),
                      title: Text(model.name),
                      // subtitle: Text(model.id),
                    ),
                  );
                },
              ),
            ),
    );
  }

  showFormModal({Listin? model}) {
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    // Caso esteja editando
    if (model != null) {
      title = "Editando ${model.name}";
      nameController.text = model.name;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: RefreshIndicator(
            onRefresh: () {
              analytics.incrementarAtualizacoesManuais();
              return refresh();
            },
            child: ListView(
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(label: Text("Nome do Listin")),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(skipButton),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          //  Criar o listin com as informacoes
                          Listin listin = Listin(
                            id: const Uuid().v1(),
                            name: nameController.text,
                          );
                          // Verificando se o Model já existe
                          if (model != null) {
                            listin.id = model.id;
                          }
                          // Salvar no firestore
                          firestore
                              .collection("listins")
                              .doc(listin.id)
                              .set(listin.toMap());
                          analytics.incrementarListasAdicionadas();

                          // Atualizar a lista
                          refresh();
                          // Fechar o Modal
                          Navigator.pop(context);
                        },
                        child: Text(confirmationButton)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  refresh() async {
    List<Listin> temp = [];

    // Busca dados
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('listins').get();

    // Adiciona em uma lista temporaria listins pegos do firebase
    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    setState(() {
      listListins = temp;
    });
  }

  void remove(Listin model) {
    firestore.collection('listins').doc(model.id).delete();
    refresh();
  }
}
