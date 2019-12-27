import Swiftline
import Commander


Group {
    $0.command(
    "branch",
    Flag("sdk", default: false, description: "是否打开分支中原生 SDK 的工程，默认为 false 不打开")
    ) { sdk in
        let openBranch = OpenBranch(sdk:sdk)
        do {
            try openBranch.open()
        } catch let error {
            print(error.localizedDescription.f.Yellow.b.Red)
        }
    }
}.run()

