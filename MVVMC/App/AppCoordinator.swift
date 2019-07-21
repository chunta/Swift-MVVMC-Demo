import Foundation
import RxSwift
import SideMenu

class AppCoordinator: BaseCoordinator {

    private let disposeBag = DisposeBag()
    private let sessionService: SessionService
    private var window = UIWindow(frame: UIScreen.main.bounds)
    
    private var drawerMenu: UISideMenuNavigationController? {
        return SideMenuManager.default.menuLeftNavigationController
    }
    
    init(sessionService: SessionService) {
        self.sessionService = sessionService
    }
    
    override func start() {
        self.window.makeKeyAndVisible()
        
        self.sessionService.sessionState == nil
            ? self.showSignIn()
            : self.showDashboard()
        
        self.subscribeToSessionChanges()
    }
    
    private func subscribeToSessionChanges() {
        self.sessionService.didSignIn
            .subscribe(onNext: { [weak self] in self?.showDashboard() })
            .disposed(by: self.disposeBag)
        
        self.sessionService.didSignOut
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                if self.drawerMenu?.isHidden ?? true {
                    self.showSignIn()
                } else {
                    self.drawerMenu?.dismiss(animated: true, completion: self.showSignIn)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func showSignIn() {
        self.removeChildCoordinators()
        
        let coordinator = AppDelegate.container.resolve(SignInCoordinator.self)!
        self.start(coordinator: coordinator)
        
        ViewControllerUtils.setRootViewController(
            window: self.window,
            viewController: coordinator.navigationController,
            withAnimation: true)
    }
    
    private func showDashboard() {
        self.removeChildCoordinators()
        
        let coordinator = AppDelegate.container.resolve(DrawerMenuCoordinator.self)!
        coordinator.navigationController = BaseNavigationController()
        self.start(coordinator: coordinator)
        
        ViewControllerUtils.setRootViewController(
            window: self.window,
            viewController: coordinator.navigationController,
            withAnimation: true)
    }
}
