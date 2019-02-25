package org.springframework.samples.petclinic.system;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.ui.ModelMap;

@Controller
class WelcomeController {

    @GetMapping("/")
    public String welcome(ModelMap map) {
        map.addAttribute("WelComeMessage", "Hello from DevSpaces");
        return "welcome";
    }
}
