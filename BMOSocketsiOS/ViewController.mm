//
//  ViewController.m
//  BMOSocketsiOS
//
//  Created by Breno on 05/04/21.
//

#import "ViewController.h"

#include <iostream>

#include <thread>
#include "BMOSocketiOS.hpp"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tvTextView;

@end

@implementation ViewController










void cppLogToTextView(BMOSocketiOS *bmo){
    while (true) {
        if (!(bmo->getSs()).empty()) {
            NSLog([NSString stringWithUTF8String:(bmo->popSs()).c_str()]);
            //(id) tvTextView = [NSString stringWithUTF8String:(bmo->popSs()).c_str()] ;
        }
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
    
    
    // SERVIDOR
    int portaSocketServidor = 5000;
    struct sockaddr_in saddr = {                        //Informações do Servidor [Como Endereço e Porta ultilizadas pelo Cliente]
        .sin_family = AF_INET,                              //Familia de Protocolo(ipv4 ou ipv6)
        
        //inet_pton(AF_INET, "0.0.0.0", &saddr.sin_addr),   //PointerTOaNumber: Insere o atual endereço de rede do SERVIDOR, seja lá qual for
        //.sin_addr.s_addr = htonl(INADDR_ANY),             //Endereço na rede local [nesse caso htonl(INADDR_ANY)=definidoPelaRede]
        .sin_addr.s_addr = INADDR_ANY,                      //Endereço na rede local [nesse caso htonl(INADDR_ANY)=definidoPelaRede]
        
        .sin_port = htons(portaSocketServidor)   //HostToNetworkShort      //Porta padrão para o Airport. Caso n funcione some +1 até que funcione
    };
    int opcao = 1;
    
    BMOSocketiOS bmo = BMOSocketiOS(saddr, opcao);
    
    
    // AF_INET=ipv4      e   AF_INET6=ipv6
    // SOCK_STREAM=TCP   e   SOCK_DGRAM=UDP
    // O terceiro argumento é para se desejassemos especificar algum protocolo
    int socketServer = bmo.criarSocketServidor(AF_INET, SOCK_STREAM, 0);
    if (socketServer == -1) {
        bmo.imprimir("Não foi possível criar o Socket! Saindo", true);
        return;
    }
    
    
    
    
    // Thread cppLogToTextView in a function pointer
    std::thread threadLogToTextView(cppLogToTextView, &bmo);
    
    
    // Define startSocketServidor in a Lambda Expression
    auto startSocketServidor = [=](BMOSocketiOS *bmo, int portaSocketServidor) {
        (bmo->startSocketServidor(portaSocketServidor, SOMAXCONN, 4096));
    };
    // Thread for startSocketServidor
    std::thread threadSocketServidor(startSocketServidor, &bmo, portaSocketServidor);
    
    
    
    
  
    threadLogToTextView.join();
    
    
    threadSocketServidor.join();
    
}





@end
