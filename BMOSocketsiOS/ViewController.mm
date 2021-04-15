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





BMOSocketiOS *bmo;






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
    
    //BMOSocketiOS bmo = BMOSocketiOS(saddr, opcao);
    std::shared_ptr<BMOSocketiOS> bmoShared{new BMOSocketiOS(saddr, opcao)};
    
    
    // AF_INET=ipv4      e   AF_INET6=ipv6
    // SOCK_STREAM=TCP   e   SOCK_DGRAM=UDP
    // O terceiro argumento é para se desejassemos especificar algum protocolo
    int socketServer = bmoShared->criarSocketServidor(AF_INET, SOCK_STREAM, 0);
    if (socketServer == -1) {
        bmoShared->imprimir("Não foi possível criar o Socket! Saindo", true);
        return;
    }
    
    
    
    // Thread cppLogToTextView in a function pointer
    std::weak_ptr<BMOSocketiOS> weakBmo(bmoShared->shared_from_this());
    //__weak __typeof__(BMOSocketiOS *) weakBmo = bmoShared;
    [self performBlockInBackground:^{
        auto strongBmo = weakBmo.lock();
        //std::shared_ptr<BMOSocketiOS> strongBmo{weakBmo.lock()};
        if (strongBmo) {
            //__typeof__(BMOSocketiOS *) strongBmo = weakBmo;
            while (true) {
                if (!(strongBmo->getSs()).empty()) {
                    NSLog(@"%@", [NSString stringWithUTF8String:(strongBmo->popSs()).c_str()]);
                    //(id) tvTextView = [NSString stringWithUTF8String:(bmo->popSs()).c_str()] ;
                }
            }
        }
    }];
    
    
    
    // Thread for startSocketServidor
    [self performBlockInBackground:^{
        auto strongBmo = weakBmo.lock();
        (strongBmo->startSocketServidor(portaSocketServidor, SOMAXCONN, 4096));
    }];
    
    
    // Define startSocketServidor in a Lambda Expression
    /*auto startSocketServidor = [=](BMOSocketiOS *bmo, int portaSocketServidor) {
        (bmo->startSocketServidor(portaSocketServidor, SOMAXCONN, 4096));
    };
    // Thread for startSocketServidor
    std::thread threadSocketServidor(startSocketServidor, &bmo, portaSocketServidor);
    
    
    
    
  
    
    
    threadSocketServidor.join();*/
    
    
    
}

- (void)performBlockInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block();
    });
}



@end
