//
//  ViewController.swift
//  Project5
//
//  Created by Christian Roese on 10/5/18.
//  Copyright © 2018 Nothin But Scorpions, LLC. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {
  
  var allWords = [String]()
  var usedWords = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                        action: #selector(promptForAnswer))
    
    if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt")
    {
      if let startWords = try? String(contentsOfFile: startWordsPath)
      {
        allWords = startWords.components(separatedBy: "\n")
      } else {
        loadDefaultWords()
      }
    }
    else
    {
      loadDefaultWords()
    }
    
    startGame()
  }
  
  func loadDefaultWords() {
    allWords = ["silkworm"]
  }
  
  func startGame()
  {
    allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
    title = allWords[0]
    usedWords.removeAll(keepingCapacity: true)
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usedWords.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
    cell.textLabel?.text = usedWords[indexPath.row]
    return cell
  }
  
  @objc func promptForAnswer()
  {
    let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
    ac.addTextField()
    
    let submitAction = UIAlertAction(title: "Submit", style: .default){
      [unowned self,ac] _ in
      let answer = ac.textFields![0]
      self.submit(answer: answer.text!)
    }
    
    ac.addAction(submitAction)
    present(ac, animated: true)
  }
  
  func submit(answer: String)
  {
    let lowerAnswer = answer.lowercased()
    
    if isPossible(word: lowerAnswer){
      if isOriginal(word: lowerAnswer){
        if isReal(word: lowerAnswer){
          usedWords.insert(answer, at: 0)
          
          let indexPath = IndexPath(row: 0, section: 0)
          tableView.insertRows(at: [indexPath], with: .automatic)
          return
        }
        else {
          showErrorMessage(errorTitle: "Word not recognized", errorMessage: "You can't just make them up, you know!")
        }
      }
      else {
        showErrorMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
      }
    } else {
      showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from '\(title!.lowercased())'!")
    }
  }
  
  func showErrorMessage(errorTitle: String, errorMessage: String) {
    let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
  
  func isPossible(word: String) -> Bool {
    var tempWord = title!.lowercased()
    
    for letter in word {
      if let pos = tempWord.range(of: String(letter)) {
        tempWord.remove(at: pos.lowerBound)
      }
      else {
        return false
      }
    }
    
    return true
  }
  
  func isOriginal(word: String) -> Bool {
    let startWord = title!.lowercased()
    return word != startWord && !usedWords.contains(word)
  }
  
  func isReal(word: String) -> Bool {
    if word.trimmingCharacters(in: CharacterSet.whitespaces).count < 3 {
      return false
    }
    
    let checker = UITextChecker()
    let range = NSMakeRange(0, word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    return misspelledRange.location == NSNotFound
  }
}

