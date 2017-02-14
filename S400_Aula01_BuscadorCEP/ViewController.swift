
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var cepTextField: UITextField!
    @IBOutlet weak var logradouroTextField: UITextField!
    @IBOutlet weak var bairroTextField: UITextField!
    @IBOutlet weak var cidadeTextField: UITextField!
    @IBOutlet weak var ufTextField: UITextField!
    
    //MARK: Propriedades
    var minhaSessao : URLSession!
    var meuCEP = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.minhaSessao = URLSession(configuration: .default)
        
        cepTextField.delegate = self

    }


    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !(cepTextField.text!.isEmpty){
            self.meuCEP = cepTextField.text!
            
            //Consultando o servidor e devolvendo a resposta
            let minhaURL = URL(string: "https://viacep.com.br/ws/\(self.meuCEP)/json/")
            
            let tarefa = self.minhaSessao.dataTask(with: minhaURL!, completionHandler: { (data : Data?, response : URLResponse?, erro: Error?) in
                if erro == nil {
                    let meuResponse = response as? HTTPURLResponse
                    
                    if meuResponse?.statusCode == 200{
                        
                        guard let dataTemp = data else {return}
                        
                        do {
                            let meuJSON = try JSONSerialization.jsonObject(with: dataTemp, options: JSONSerialization.ReadingOptions()) as! [String : AnyObject]
                            
                            if let cep = meuJSON["cep"]{
                                DispatchQueue.main.async {
                                    self.cepTextField.text = (cep as! String)
                                    self.logradouroTextField.text = meuJSON["logradouro"] as! String?
                                    self.bairroTextField.text = meuJSON["bairro"] as! String?
                                    self.cidadeTextField.text = meuJSON["localidade"] as! String?
                                    self.ufTextField.text = meuJSON["uf"] as! String?
                                }
                            }
                            
                            if (meuJSON["erro"] != nil){
                                
                                DispatchQueue.main.async {
                                    let alerta = UIAlertController(title: "Alerta", message: "CEP informado não existe", preferredStyle: .alert)
                                    alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    
                                    self.present(alerta, animated: true)
                                }
                                
                            }
                            
                        } catch {}
                        
                    } else{
                        DispatchQueue.main.async {
                            let alerta = UIAlertController(title: "Alerta", message: "Erro na rede ou CEP inválido", preferredStyle: .alert)
                            alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            self.present(alerta, animated: true)
                        }
                    }
                    
                }
                
            })
            
            tarefa.resume()
            
        } else {
            
            let alerta = UIAlertController(title: "Alerta", message: "Preencha o campo CEP", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alerta, animated: true)
            
        }
        
        return true
        
    }
    
    
    //MARK: Métodos de UITextFieldDelegate
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }

    
    
}



