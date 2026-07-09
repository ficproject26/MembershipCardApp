const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        if (isDirectory && !dirPath.includes('node_modules') && !dirPath.includes('.git')) {
            walkDir(dirPath, callback);
        } else if (!isDirectory && dirPath.endsWith('.dart') && !dirPath.includes('linux') && !dirPath.includes('windows') && !dirPath.includes('macos')) {
            callback(dirPath);
        }
    });
}

walkDir('c:/Users/Admin/Desktop/membership_card', function(filepath) {
    let content = fs.readFileSync(filepath, 'utf-8');
    
    // We want to match:
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Message')));
    
    let regex = /ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*behavior:\s*SnackBarBehavior\.floating,\s*width:\s*400,\s*shape:\s*RoundedRectangleBorder\(borderRadius:\s*BorderRadius\.circular\(10\)\),\s*content:\s*(Text\([^)]+\))(?:,\s*backgroundColor:\s*[^)]+\))?\s*\)\s*,?\s*\);?/g;
    
    let newContent = content.replace(regex, function(match, p1) {
        return 'showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: ' + p1 + ', actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));';
    });
    
    if (newContent !== content) {
        fs.writeFileSync(filepath, newContent, 'utf-8');
        console.log('Replaced in ' + filepath);
    }
});
