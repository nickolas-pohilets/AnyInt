import PackagePlugin
import Foundation

@main
struct CopyFiles: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let outputDir = context.pluginWorkDirectory.appending("CopiedFiles")
        try FileManager.default.createDirectory(atPath: outputDir.string, withIntermediateDirectories: true)

        let targetDir = target.directory
        let name = String(targetDir.lastComponent.split(separator: "_")[0])
        let inputDir = targetDir.removingLastComponent().appending(name)

        return [.prebuildCommand(
            displayName: "Copying Files",
            executable: try context.tool(named: "cp").path,
            arguments: [ "-R", inputDir, outputDir ],
            outputFilesDirectory: outputDir.appending(name))
        ]
    }
}
