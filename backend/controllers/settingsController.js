exports.getSettings =
async(req,res)=>{

  res.json({

    appName:"BusBuddy",

    version:"2.0",

    admin:"Administrator",

    theme:"Purple"

  });

};